if {[llength [info commands save_image]] == 0} {
  return
}

if {[llength [info commands original_save_image]] == 0} {
  rename save_image original_save_image
}

proc scaled_save_image_args {args} {
  set scaled_args {}
  set scale 1.0

  if {[info exists ::env(REPORT_IMAGE_SCALE)] && $::env(REPORT_IMAGE_SCALE) ne ""} {
    set scale [expr {double($::env(REPORT_IMAGE_SCALE))}]
  }

  for {set index 0} {$index < [llength $args]} {incr index} {
    set arg [lindex $args $index]
    if {$arg eq "-resolution" && $index + 1 < [llength $args]} {
      incr index
      set resolution [lindex $args $index]
      lappend scaled_args -resolution [expr {double($resolution) / $scale}]
    } else {
      lappend scaled_args $arg
    }
  }

  return $scaled_args
}

proc extract_report_resolution {args} {
  for {set index 0} {$index < [llength $args]} {incr index} {
    if {[lindex $args $index] eq "-resolution" && $index + 1 < [llength $args]} {
      return [expr {double([lindex $args [expr {$index + 1}]])}]
    }
  }

  return 1.0
}

proc instance_label_size {master label_text resolution} {
  if {[info exists ::env(REPORT_LABEL_SIZE)] && $::env(REPORT_LABEL_SIZE) ne ""} {
    return $::env(REPORT_LABEL_SIZE)
  }

  set cell_width_microns [ord::dbu_to_microns [$master getWidth]]
  set available_pixels [expr {$cell_width_microns / $resolution}]
  set text_length [string length $label_text]
  if {$text_length < 1} {
    set text_length 1
  }

  set estimated_size [expr {int(($available_pixels * 0.8) / (0.62 * $text_length))}]
  if {$estimated_size < 4} {
    return 4
  }
  if {$estimated_size > 14} {
    return 14
  }

  return $estimated_size
}

proc add_instance_name_labels {resolution} {
  set block [ord::get_db_block]

  gui::clear_labels
  gui::set_display_controls "Misc/Labels" visible true

  foreach inst [$block getInsts] {
    set master [$inst getMaster]
    set master_type [$master getType]
    if {$master_type eq "CORE_SPACER" || $master_type eq "CORE_WELLTAP"} {
      continue
    }

    set label_text [$master getName]
    set label_size [instance_label_size $master $label_text $resolution]

    set origin [$inst getLocation]
    set center_x [expr {int([lindex $origin 0] + [$master getWidth] / 2)}]
    set center_y [expr {int([lindex $origin 1] + [$master getHeight] / 2)}]

    add_label \
      -position [list [ord::dbu_to_microns $center_x] [ord::dbu_to_microns $center_y]] \
      -anchor center \
      -color yellow \
      -size $label_size \
      $label_text
  }
}

proc export_extra_report_images {original_args scaled_args} {
  set filename [lindex $original_args end]
  set basename [file tail $filename]

  if {$basename eq "final_placement.webp"} {
    set resolution [extract_report_resolution {*}$scaled_args]
    add_instance_name_labels $resolution
    original_save_image {*}$scaled_args
    gui::clear_labels
  }
}

proc save_image {args} {
  set scaled_args [scaled_save_image_args {*}$args]

  original_save_image {*}$scaled_args
  export_extra_report_images $args $scaled_args
}