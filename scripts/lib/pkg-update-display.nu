# Keep terminal presentation separate from the complete checker records.

def wrap-cell [value: string, width: int] {
    if $value == '' { return '—' }
    $value | split chars | chunks $width | each { str join } | str join (char newline)
}

def column-width [rows: list, column: string, limit: int] {
    let longest = ($rows | get $column | append $column | each { str length } | math max)
    [$limit $longest] | math min
}

export def format-updates [rows: list] {
    let colors = {current: green, update: yellow, ahead: cyan, changed: yellow, skipped: dark_gray, error: red}
    let color = ($env.config.use_ansi_coloring != false) and ($env.NO_COLOR? == null)
    let display = ($rows | each {|row|
        $row | update current {|r| short-version $r.current } | update latest {|r| short-version $r.latest }
    })
    let package_width = (column-width $display package 20)
    let current_width = (column-width $display current 16)
    let latest_width = (column-width $display latest 16)
    let source_width = ([10 ((term size).columns - $package_width - $current_width - $latest_width - 7 - 16)] | math max)
    $display | each {|row|
        let status = if $color {
            $"(ansi ($colors | get $row.status))($row.status)(ansi reset)"
        } else { $row.status }
        {
            package: (wrap-cell $row.package $package_width)
            status: $status
            current: (wrap-cell $row.current $current_width)
            latest: (wrap-cell $row.latest $latest_width)
            source: (wrap-cell $row.source $source_width)
        }
    } | table --index false --theme rounded --expand
}

def short-version [value: string] {
    if $value == '' { '—' } else if $value =~ '^[0-9a-f]{40}$' {
        $value | str substring 0..<12
    } else { $value }
}

export def format-errors [rows: list] {
    let errors = ($rows | where status == error)
    let package_width = (column-width $errors package 20)
    let source_width = (column-width $errors source 24)
    let error_width = ([20 ((term size).columns - $package_width - $source_width - 10)] | math max)
    $errors | each {|row|
        {
            package: (wrap-cell $row.package $package_width)
            source: (wrap-cell $row.source $source_width)
            error: (wrap-cell $row.error $error_width)
        }
    } | table --index false --theme rounded --expand
}
