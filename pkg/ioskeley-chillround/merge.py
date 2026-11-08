"""Combine Ioskeley's terminal glyphs with ChillRoundF on a two-cell CJK grid."""

import copy
import os
import sys
import unicodedata
from pathlib import Path

from fontTools import subset
from fontTools.merge import Merger
from fontTools.misc.timeTools import timestampSinceEpoch
from fontTools.pens.recordingPen import DecomposingRecordingPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont
from fontTools.ttLib.scaleUpem import scale_upem

FAMILY = "Ioskeley ChillRound Mono"
STYLES = {
    "Regular": (400, False),
    "Bold": (700, False),
    "Italic": (400, True),
    "BoldItalic": (700, True),
}


def subset_font(font, unicodes):
    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=unicodes)
    subsetter.subset(font)


def sort_features(font):
    # Feature lists must remain sorted after concatenating the source tables.
    for tag in ("GSUB", "GPOS"):
        if tag not in font:
            continue
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


def main(latin_dir, cjk_dir, output_dir):
    output = Path(output_dir)
    output.mkdir(parents=True, exist_ok=True)
    timestamp = timestampSinceEpoch(int(os.environ["SOURCE_DATE_EPOCH"]))
    for style, (weight, italic) in STYLES.items():
        latin = TTFont(Path(latin_dir) / f"IoskeleyMonoTermNerdFontMono-{style}.ttf")
        cjk = TTFont(
            Path(cjk_dir) / f"ChillRoundF{'Bold' if weight == 700 else 'Regular'}.ttf"
        )
        copyright_notice = "\n".join(
            f["name"].getDebugName(0) or "" for f in (latin, cjk)
        )
        (output / "COPYRIGHT.txt").write_text(copyright_notice + "\n", encoding="utf-8")
        latin_cmap = latin.getBestCmap()
        expected_cmap = set(latin_cmap) | set(cjk.getBestCmap())
        cell = latin["hmtx"][latin_cmap[ord("M")]][0]
        # Latin, programming symbols and Nerd Font icons always take priority.
        subset_font(cjk, set(cjk.getBestCmap()) - set(latin_cmap))
        scale_upem(cjk, latin["head"].unitsPerEm)
        advances = {}
        for cp, name in cjk.getBestCmap().items():
            width = 0 if unicodedata.category(chr(cp)).startswith("M") else cell
            if unicodedata.east_asian_width(chr(cp)) in ("W", "F"):
                width = 2 * cell
            if name in advances and advances[name] != width:
                raise ValueError(f"Conflicting cell widths for {name}")
            advances[name] = width
        glyph_set = cjk.getGlyphSet()
        shifted_glyphs = {}
        shifted_metrics = {}
        for name, width in advances.items():
            advance, bearing = cjk["hmtx"][name]
            shift = (width - advance) // 2
            outline = DecomposingRecordingPen(glyph_set)
            glyph_set[name].draw(outline)
            pen = TTGlyphPen(glyph_set)
            outline.replay(TransformPen(pen, (1, 0, 0, 1, shift, 0)))
            shifted_glyphs[name] = pen.glyph()
            shifted_metrics[name] = (width, bearing + shift)
        for name, glyph in shifted_glyphs.items():
            cjk["glyf"][name] = glyph
            cjk["hmtx"][name] = shifted_metrics[name]
        # Chinese uses upright glyphs and no proportional kerning or substitutions.
        # Keep Ioskeley's complete shaping tables and hinting programs.
        for tag in ("GSUB", "GPOS", "GDEF", "vhea", "vmtx", "DSIG"):
            if tag in cjk:
                del cjk[tag]
        for tag in ("PfEd", "DSIG"):
            if tag in latin:
                del latin[tag]
        metrics = {tag: copy.deepcopy(latin[tag]) for tag in ("hhea", "OS/2", "post")}
        latin.save("latin.ttf")
        cjk.save("cjk.ttf")
        merged = Merger().merge(["latin.ttf", "cjk.ttf"])
        sort_features(merged)
        for tag, table in metrics.items():
            if tag != "post":
                merged[tag] = table
        merged["OS/2"].recalcUnicodeRanges(merged)
        merged["OS/2"].recalcCodePageRanges(merged)
        merged["post"].isFixedPitch = 1
        merged["post"].italicAngle = metrics["post"].italicAngle
        names = merged["name"]
        names.names = [n for n in names.names if n.nameID >= 256]
        subfamily = "Bold Italic" if style == "BoldItalic" else style
        ps_name = f"IoskeleyChillRoundMono-{style}"
        values = {
            0: copyright_notice,
            1: FAMILY,
            2: subfamily,
            3: f"1.000;{ps_name}",
            4: f"{FAMILY} {subfamily}",
            5: "Version 1.000",
            6: ps_name,
            10: "Merged from Ioskeley Mono Term Nerd Font Mono and ChillRoundF.",
            13: "Licensed under the SIL Open Font License, Version 1.1.",
            14: "https://openfontlicense.org/",
            16: FAMILY,
            17: subfamily,
        }
        for name_id, value in values.items():
            names.setName(value, name_id, 3, 1, 0x409)
        merged["head"].created = merged["head"].modified = timestamp
        merged.recalcTimestamp = False
        destination = output / f"{ps_name}.ttf"
        merged.save(destination)
        with TTFont(destination) as saved:
            saved.ensureDecompiled()
            cmap = saved.getBestCmap()
            if set(cmap) != expected_cmap:
                raise ValueError("Character coverage changed during merging")
            for cp, original in latin_cmap.items():
                if saved["hmtx"][cmap[cp]] != latin["hmtx"][original]:
                    raise ValueError(f"Latin metrics changed for U+{cp:04X}")
            for char in "中文，。":
                if saved["hmtx"][cmap[ord(char)]][0] != 2 * cell:
                    raise ValueError(f"CJK grid alignment failed for {char}")
            if (
                saved["OS/2"].usWeightClass != weight
                or bool(saved["head"].macStyle & 2) != italic
            ):
                raise ValueError("Incorrect weight or italic style")
            print(f"Validated {destination}: {len(cmap)} characters", flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
