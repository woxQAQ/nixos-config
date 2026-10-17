"""Build static UI fonts with Inter's western glyphs and Noto's SC glyphs."""

import copy
import os
import sys
from pathlib import Path

from fontTools import subset
from fontTools.merge import Merger
from fontTools.misc.timeTools import timestampSinceEpoch
from fontTools.ttLib import TTFont, newTable
from fontTools.ttLib.scaleUpem import scale_upem
from fontTools.varLib.instancer import instantiateVariableFont

FAMILY = "Inter Noto Sans SC"
STYLES = {
    100: "Thin",
    200: "ExtraLight",
    300: "Light",
    400: "Regular",
    500: "Medium",
    600: "SemiBold",
    700: "Bold",
    800: "ExtraBold",
    900: "Black",
}


def subset_font(font, unicodes, *, chinese=False):
    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.name_legacy = True
    if chinese:
        # Keep every encoded character, with SC as the default layout language.
        # Other regional alternates would exceed OpenType's 65,535-glyph limit
        # after adding Inter. Explicit ZHS records would also shadow Inter's
        # default Latin features in Chinese-language applications.
        scripts = {
            record.ScriptTag
            for tag in ("GSUB", "GPOS")
            for record in font[tag].table.ScriptList.ScriptRecord
        }
        options.layout_scripts = [f"{script}.dflt" for script in sorted(scripts)]
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=unicodes)
    subsetter.subset(font)


def sort_layout_features(font):
    # Merger concatenates feature lists; OpenType requires alphabetical tags.
    # Remap language-system references along with the reordered records.
    for tag in ("GSUB", "GPOS"):
        table = font[tag].table
        records = table.FeatureList.FeatureRecord
        order = sorted(range(len(records)), key=lambda i: records[i].FeatureTag)
        indices = {old: new for new, old in enumerate(order)}
        table.FeatureList.FeatureRecord = [records[i] for i in order]
        for record in table.ScriptList.ScriptRecord:
            script = record.Script
            languages = [record.LangSys for record in script.LangSysRecord]
            if script.DefaultLangSys is not None:
                languages.append(script.DefaultLangSys)
            for language in languages:
                language.FeatureIndex = sorted(
                    indices[i] for i in language.FeatureIndex
                )
                if language.ReqFeatureIndex != 0xFFFF:
                    language.ReqFeatureIndex = indices[language.ReqFeatureIndex]


def set_names(font, weight, style, copyright_notice):
    # Preserve feature-label names (IDs >= 256) referenced by Inter's GSUB.
    names = font["name"]
    names.names = [record for record in names.names if record.nameID >= 256]
    legacy_family = FAMILY if weight in (400, 700) else f"{FAMILY} {style}"
    postscript_name = f"InterNotoSansSC-{style}"
    values = {
        0: copyright_notice,
        1: legacy_family,
        2: "Bold" if weight == 700 else "Regular",
        3: f"1.000;{postscript_name}",
        4: f"{FAMILY} {style}",
        5: "Version 1.000",
        6: postscript_name,
        10: "Merged from Inter and Noto Sans CJK SC; not an upstream release.",
        13: "Licensed under the SIL Open Font License, Version 1.1.",
        14: "https://openfontlicense.org/",
        16: FAMILY,
        17: style,
    }
    for name_id, value in values.items():
        names.setName(value, name_id, 3, 1, 0x409)
        names.setName(value, name_id, 1, 0, 0)

    font["OS/2"].usWeightClass = weight
    # Legacy style linking pairs Regular/Bold; other weights have their own
    # legacy families. Typographic names group all nine in modern applications.
    font["OS/2"].fsSelection = (1 << 7) | ((1 << 5) if weight == 700 else (1 << 6))
    font["head"].macStyle = 1 if weight == 700 else 0


def main(inter_path, noto_path, output_path):
    output = Path(output_path)
    output.mkdir(parents=True, exist_ok=True)
    inter = TTFont(inter_path)
    noto = TTFont(noto_path)
    copyright_notice = "\n".join(font["name"].getDebugName(0) for font in (inter, noto))
    (output / "COPYRIGHT.txt").write_text(copyright_notice + "\n", encoding="utf-8")

    expected_cmap = set(inter.getBestCmap()) | set(noto.getBestCmap())
    # Noto owns CJK punctuation and half/fullwidth forms even if Inter adds
    # coverage there in a future release. All other Inter coverage takes priority.
    inter_unicodes = {
        cp
        for cp in inter.getBestCmap()
        if not (0x3000 <= cp <= 0x303F or 0xFF00 <= cp <= 0xFFEF)
    }
    subset_font(inter, inter_unicodes)
    subset_font(noto, set(noto.getBestCmap()) - inter_unicodes, chinese=True)
    # fontTools cannot instantiate/merge Noto's variable BASE table. Use the
    # fonts' normal baseline metrics rather than ship unresolved variation data.
    del noto["BASE"]
    inter.save("inter-variable.ttf")
    noto.save("noto-variable.ttf")

    timestamp = timestampSinceEpoch(int(os.environ["SOURCE_DATE_EPOCH"]))
    for weight, style in STYLES.items():
        print(f"Building {FAMILY} {style}", flush=True)
        latin = instantiateVariableFont(
            TTFont("inter-variable.ttf"), {"wght": weight, "opsz": 14}, inplace=True
        )
        cjk = instantiateVariableFont(
            TTFont("noto-variable.ttf"), {"wght": weight}, inplace=True
        )
        # Preserve Inter's coordinates; scale Noto uniformly without changing
        # its em-relative proportions or fullwidth advances.
        scale_upem(cjk, latin["head"].unitsPerEm)

        # Noto supplies vertical metrics. Fill them for Inter as well so the
        # merged vmtx covers every glyph and vertical CJK layout remains usable.
        latin["vhea"] = copy.deepcopy(cjk["vhea"])
        latin["vmtx"] = newTable("vmtx")
        latin["vmtx"].metrics = {
            name: (
                latin["head"].unitsPerEm,
                cjk["OS/2"].sTypoAscender - getattr(glyph, "yMax", 0),
            )
            for name, glyph in latin["glyf"].glyphs.items()
        }
        for font, filename in ((latin, "latin.ttf"), (cjk, "cjk.ttf")):
            # Static instances no longer need variation metadata or signatures.
            for tag in ("STAT", "DSIG"):
                if tag in font:
                    del font[tag]
            font.save(filename)

        merged = Merger().merge(["latin.ttf", "cjk.ttf"])
        sort_layout_features(merged)
        set_names(merged, weight, style, copyright_notice)
        merged["head"].created = merged["head"].modified = timestamp
        merged.recalcTimestamp = False
        if len(merged.getGlyphOrder()) > 65535:
            raise ValueError("Merged font exceeds OpenType's glyph limit")
        if set(merged.getBestCmap()) != expected_cmap:
            raise ValueError("Character coverage changed during merging")

        destination = output / f"InterNotoSansSC-{style}.ttf"
        merged.save(destination)
        # Reopen the actual artifact, including all tables, before installing.
        with TTFont(destination) as saved:
            saved.ensureDecompiled()
            if "fvar" in saved or saved["name"].getDebugName(16) != FAMILY:
                raise ValueError(f"Invalid static font: {destination}")


if __name__ == "__main__":
    main(*sys.argv[1:])
