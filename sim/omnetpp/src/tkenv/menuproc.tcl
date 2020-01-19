#=================================================================
#  MENUPROC.TCL - part of
#
#                     OMNeT++/OMNEST
#            Discrete System Simulation in C++
#
#=================================================================

#----------------------------------------------------------------#
#  Copyright (C) 1992-2008 Andras Varga
#
#  This file is distributed WITHOUT ANY WARRANTY. See the file
#  `license' for details on this and other legal matters.
#----------------------------------------------------------------#

#------
# Parts of this file were created using Stewart Allen's Visual Tcl (vtcl)
#------

#===================================================================
#    HELPER/GUI PROCEDURES
#===================================================================

proc network_present {} {
    if [opp_isnull [opp_object_systemmodule]] {
       messagebox {Error} {No network has been set up yet.} info ok
       return 0
    }
    return 1
}

proc network_ready {} {
    if {[network_present] == 0} {return 0}

    if {[is_simulation_ok] == 1} {
        return 1
    } else {
        set ans [messagebox {Warning} {Cannot continue this simulation. Rebuild network?} question yesno]
        if {$ans == "yes"} {
            rebuild
            return [is_simulation_ok]
        } else {
            return 0
        }
    }
}

proc is_simulation_ok {} {
    set state [opp_getsimulationstate]
    if {$state == "SIM_NEW" || $state == "SIM_RUNNING" || $state == "SIM_READY"} {
        return 1
    } else {
        return 0
    }
}

proc is_running {} {
    set state [opp_getsimulationstate]
    if {$state == "SIM_RUNNING" || $state == "SIM_BUSY"} {
        return 1
    } else {
        return 0
    }
}

proc check_running {} {
    if {[opp_getsimulationstate] == "SIM_RUNNING"} {
       messagebox {Warning} {Sorry, you cannot do this while the simulation\
                             is running. Please stop it first.} info ok
       return 1
    }
    if {[opp_getsimulationstate] == "SIM_BUSY"} {
       messagebox {Warning} {The simulation is waiting for external synchronization -- press STOP to interrupt it.} info ok
       return 1
    }
    return 0
}

#===================================================================
#    MENU PROCEDURES
#===================================================================

proc about {} {
    # implements Help|About
    global OMNETPP_RELEASE OMNETPP_EDITION OMNETPP_BUILDID
    aboutDialog "About OMNeT++/OMNEST" "
This simulation model is based on:

OMNeT++/OMNEST
Discrete Event Simulation Framework
" \
"(C) 1992-2008 Andras Varga
Release: $OMNETPP_RELEASE, build: $OMNETPP_BUILDID, edition: $OMNETPP_EDITION

NO WARRANTY -- see license for details."
}

proc exit_omnetpp {} {
    global config

    set isrunning [is_running]
    set state [opp_getsimulationstate]

    if {$config(confirm-exit)} {
        if [opp_isnotnull [opp_object_systemmodule]] {
            if {$isrunning} {
                set ans [messagebox {Warning} {The simulation is currently running. Do you really want to quit?} warning yesno]
                if {$ans == "no"} {
                    return
                }
            } elseif {$state == "SIM_READY"} {
                set ans [messagebox {Warning} {Do you want to call finish() before exiting?} warning yesnocancel]
                if {$ans == "yes"} {
                    # no catch{}: exceptions are handled inside
                    opp_finish_simulation
                } elseif {$ans == "no"} {
                    # nothing to do
                } elseif {$ans == "cancel"} {
                    return
                }
            } else {
                #set ans [messagebox {Warning} {Do you really want to quit?} warning yesno]
            }
        }
    }

    if {$isrunning} {
       opp_stopsimulation
    }

    # save settings (fonts etc) globally, and inspector list locally
    save_tkenvrc "~/.tkenvrc" 1 0 1
    save_tkenvrc ".tkenvrc"   0 1 1 "# Partial Tkenv config file -- see \$HOME/.tkenvrc as well"

    opp_exitomnetpp
}

proc create_snapshot {} {
    # implements File|Create snapshot

    if {[network_present] == 0} return

    set label ""
    set ok [inputbox {Snapshot} {Enter label for current simulation snapshot:} label]
    if {$ok == 1} {
        if [catch {opp_createsnapshot $label} err] {
          messagebox {Error} "Error: $err" error ok
          return
        }
        set snapshotfile [opp_getfilename snapshot]
        if {$snapshotfile==""} {
            messagebox {Snapshot created} "Current state of simulation has been saved." info ok
        } else {
            set ans [messagebox {Snapshot created} "Current state of simulation has been \
saved into \"$snapshotfile\". Do you want to open it now in a file viewer window?" question yesno]
            if {$ans == "yes"} {
                view_snapshotfile
            }
        }
    }
}

proc load_nedfile {} {
   global config

   set fname $config(last-nedfile)

   if {[string compare [file tail $fname] $fname]==0} {
       set dir "."
   } else {
       set dir [file dirname $fname]
   }

   set fname [file tail $fname]
   set fname [tk_getOpenFile -defaultextension ".ned" \
              -initialdir $dir -initialfile $fname \
              -filetypes {{{NED files} {*.ned}} {{All files} {*}}}]

   if {$fname!=""} {
      set config(last-nedfile) $fname
      if [catch {opp_loadnedfile $fname} err] {
        opp_updateinspectors
        messagebox {Error} "Error: $err" error ok
        return
      }
      opp_updateinspectors
   }
}

proc new_network {} {
    # implements File|New network...

    if [check_running] return

    # get list of network names
    set networks [opp_getnetworktypes]
    set localpackage [opp_getsimoption localpackage]
    set networknames {}
    set localnetworknames {}
    foreach net $networks {
        set networkname [opp_getobjectname $net]
        set networkqname [opp_getobjectfullname $net]
        if {"$localpackage.$networkname" == "$networkqname"} {
            lappend localnetworknames $networkname
        } else {
            lappend networknames $networkqname
        }
    }
    set localnetworknames [lsort -dictionary $localnetworknames]
    set networknames [lsort -dictionary $networknames]

    set networknames [concat $localnetworknames $networknames]

    # pop up dialog, with current network as default
    set netname [opp_getnetworktype]
    set ok [comboSelectionDialog "Set up network" "Set up a network. NOTE: The network will use parameter values defined in the \n\[General\] section of the ini file." "Select network:" netname $networknames]
    if {$ok == 1} {
       busy "Setting up network..."
       opp_newnetwork $netname
       reflect_record_eventlog
       busy

       if [opp_isnotnull [opp_object_systemmodule]] {
           busy "Opening graphical network inspector..."
           opp_inspect [opp_object_systemmodule] (default)
           busy

           # tell plugins about it
           busy "Notifying Tcl plugins..."
           notifyPlugins newNetwork
           busy
       }
    }
}

proc new_run {} {
    # implements File|New run...

    if [check_running] return

    set configname [opp_getactiveconfigname]
    set runnumber  [opp_getactiverunnumber]

    # pop up selection dialog
    set ok [runSelectionDialog configname runnumber]
    if {$ok == 1} {
       # puts "DBG: selected $configname $runnumber"
       busy "Setting up network..."
       opp_newrun $configname $runnumber
       reflect_record_eventlog
       busy

       if [opp_isnotnull [opp_object_systemmodule]] {
           busy "Opening graphical network inspector..."
           opp_inspect [opp_object_systemmodule] (default)
           busy

           # tell plugins about it
           busy "Notifying Tcl plugins..."
           notifyPlugins newNetwork
           busy
       }
    }
}

proc edit_copy {{w .main.text}} {
   # implements Edit|Copy
   tk_textCopy $w
}

proc edit_find {{w .main.text}} {
   # implements Edit|Find...
   findDialog $w
}

proc edit_findnext {{w .main.text}} {
   # implements Edit|Find next
   findNext $w
}

proc edit_filterwindowcontents {{w ".main.text"}} {
   # implements Edit|Filter window contents...
   if {$w==".main.text"} {
       mainlogwindow_filterdialog
   } else {
       set w [winfo toplevel $w]
       modulewindow_filterdialog [winfo toplevel $w]
   }
}

proc toggle_treeview {} {
   global config widgets

   if {$config(display-treeview)==1} {
       set config(display-treeview) 0
       pack forget $widgets(manager)
       .toolbar.tree config -relief flat
   } else {
       set config(display-treeview) 1
       pack $widgets(manager) -before .main.text -expand 0 -fill y  -side left
       .toolbar.tree config -relief sunken
       updateTreeManager
   }
}

proc toggle_timeline {} {
   global config widgets

   if {$config(display-timeline)==1} {
       set config(display-timeline) 0
       pack forget $widgets(timeline)
       .toolbar.tline config -relief flat
   } else {
       set config(display-timeline) 1
       pack $widgets(timeline) -before .main -anchor center -expand 0 -fill x -side top
       .toolbar.tline config -relief sunken
       redraw_timeline
   }
}

proc toggle_record_eventlog {} {
   if {[opp_getsimoption record_eventlog]==1} {
       opp_setsimoption record_eventlog 0
   } else {
       opp_setsimoption record_eventlog 1
   }
   if {[opp_eventlogrecording hasintervals]} {
       messagebox {Eventlog Recording} "Switching to manual control of eventlog recording -- the recording intervals specified in the configuration will be ignored." info ok
       opp_eventlogrecording clearintervals
   }
   reflect_record_eventlog
}

proc reflect_record_eventlog {} {
   global config widgets

   if {[opp_getsimoption record_eventlog]==1} {
       .toolbar.eventlog config -relief sunken
   } else {
       .toolbar.eventlog config -relief flat
   }
}

proc set_gui_for_runmode {mode {modinspwin ""} {untilmode ""}} {
    global opp
    set w $modinspwin
    if {$w!="" && ![winfo exists $w]} {set w ""}

    set default_iconbutton_relief "flat"
    .toolbar.step config -relief $default_iconbutton_relief
    .toolbar.run config -relief $default_iconbutton_relief
    .toolbar.fastrun config -relief $default_iconbutton_relief
    .toolbar.exprrun config -relief $default_iconbutton_relief
    catch {$opp(sunken-run-button) config -relief $default_iconbutton_relief}
    remove_stopdialog

    if {$w==""} {
        if {$mode=="step"} {
            .toolbar.step config -relief sunken
        } elseif {$mode=="slow"} {
            .toolbar.run config -relief sunken
        } elseif {$mode=="normal"} {
            .toolbar.run config -relief sunken
        } elseif {$mode=="fast"} {
            .toolbar.fastrun config -relief sunken
        } elseif {$mode=="express"} {
            .toolbar.exprrun config -relief sunken
            display_stopdialog
        } elseif {$mode=="notrunning"} {
            .toolbar.until config -relief $default_iconbutton_relief
        } else {
            error "wrong mode parameter $mode"
        }
    } else {
        if {$mode=="normal"} {
            $w.toolbar.mrun config -relief sunken
            set opp(sunken-run-button) $w.toolbar.mrun
        } elseif {$mode=="fast"} {
            $w.toolbar.mfast config -relief sunken
            set opp(sunken-run-button) $w.toolbar.mfast
        } elseif {$mode=="express"} {
            display_stopdialog
        } elseif {$mode=="notrunning"} {
            .toolbar.until config -relief $default_iconbutton_relief
        } else {
            error "wrong mode parameter $mode with module inspector"
        }
    }

    if {$untilmode=="until_on"} {
        .toolbar.until config -relief sunken
    } elseif {$untilmode=="until_off"} {
        .toolbar.until config -relief $default_iconbutton_relief
    } elseif {$untilmode!=""} {
        error "wrong untilmode parameter $mode"
    }
}

proc one_step {} {
    # implements Simulate|One step

    if [is_running] {
        set_gui_for_runmode step
        opp_stopsimulation
    } else {
        if {![network_ready]} {return}
        set_gui_for_runmode step
        opp_onestep
        set_gui_for_runmode notrunning
    }
}

proc runsimulation {mode} {
    if [is_running] {
        set_gui_for_runmode $mode
        opp_set_run_mode $mode
        opp_set_run_until_module
    } else {
        if {![network_ready]} {return}
        set_gui_for_runmode $mode
        opp_run $mode
        set_gui_for_runmode notrunning
    }
}

proc run_slow {} {
    # implements Simulate|Slow execution
    runsimulation slow
}

proc run_normal {} {
    # implements Simulate|Run
    runsimulation normal
}

proc run_fast {} {
    # implements Simulate|Fast Run
    runsimulation fast
}

proc run_express {} {
    # implements Simulate|Express Run
    runsimulation express
}

proc run_until {} {
    # implements Simulate|Run until...

    if {[network_ready] == 0} {
       return
    }

    set time ""
    set event ""
    set msg ""
    set mode ""    ;# will be set to Normal, Fast or Express

    set ok [rununtil_dialog time event msg mode]
    if {$ok==0} return

    if {$mode=="Normal"} {
        set mode "normal"
    } elseif {$mode=="Fast"} {
        set mode "fast"
    } elseif {$mode=="Express"} {
        set mode "express"
    } else {
        set mode "normal"
    }

    set untilmode "until_on"
    if {$time=="" && $event=="" && $msg==""} {set until_on "until_off"}

    if [is_running] {
        if [catch {
            set_gui_for_runmode $mode "" $untilmode
            opp_set_run_mode $mode
            opp_set_run_until $time $event $msg
        } err] {
            messagebox {Error} "Error: $err" error ok
        }
    } else {
        if {![network_ready]} {return}
        if [catch {
            set_gui_for_runmode $mode "" $untilmode
            opp_run $mode $time $event $msg
        } err] {
            messagebox {Error} "Error: $err" error ok
        }
        set_gui_for_runmode notrunning
    }
}

proc run_until_msg {msg mode} {
    if {[network_ready] == 0} {
       return
    }
    # mode must be "normal", "fast" or "express"
    if [is_running] {
        if [catch {
            set_gui_for_runmode $mode "" "until_on"
            opp_set_run_mode $mode
            opp_set_run_until "" "" $msg
        } err] {
            messagebox {Error} "Error: $err" error ok
        }
    } else {
        if [catch {
            set_gui_for_runmode $mode "" "until_on"
            opp_run $mode "" "" $msg
        } err] {
            messagebox {Error} "Error: $err" error ok
        }
        set_gui_for_runmode notrunning
    }
}


proc start_all {} {

    if [check_running] return

    if {[network_present] == 0} return
    opp_start_all
}

proc call_finish {} {

    # check state is not SIM_RUNNING
    if [check_running] return

    # check state is not SIM_NONET
    if {[network_present] == 0} return

    # check state is not SIM_FINISHCALLED
    if {[opp_getsimulationstate] == "SIM_FINISHCALLED"} {
       messagebox {Error} {finish() has been invoked already.} info ok
       return
    }

    # check state is not SIM_ERROR
    if {[opp_getsimulationstate] == "SIM_ERROR"} {
       set ans [messagebox {Warning} \
                  {Simulation was stopped with error, calling finish() might produce unexpected results. Proceed anyway?} \
                  question yesno]
       if {$ans == "no"} {
           return
       }
    } else {
       set ans [messagebox {Question} \
                  {Do you want to conclude this simulation run and invoke finish() on all modules?} \
                  question yesno]
       if {$ans == "no"} {
           return
       }
    }

    busy "Invoking finish() on all modules..."
    opp_finish_simulation
    busy
}

proc rebuild {} {
    # implements Simulate|Rebuild

    if [check_running] return

    if {[network_present] == 0} return
    busy "Rebuilding network..."
    opp_rebuild
    reflect_record_eventlog
    busy
}


proc stop_simulation {} {
    # implements Simulate|Stop
    if {[opp_getsimulationstate] == "SIM_RUNNING" || [opp_getsimulationstate] == "SIM_BUSY"} {
       # "opp_stopsimulation" just *asks* the simulation to stop, causing it to return
       # from the "opp_run" command.
       # "set_gui_for_runmode notrunning" will be called after "opp_run" has returned.
       opp_stopsimulation
    }

    # this proc doubles as "stop layouting", when in graphical module inspectors
    global stoplayouting
    set stoplayouting 1
}

proc message_windows {} {
    # implements Trace|Message sending...
    if {[network_present] == 0} return
    create_messagewindow .messagewindow
}

proc clear_windows {} {
    # implements Trace|Clear windows...
    # also called back from C++ code
    # TBD: should delete the contents of module windows as well
    .main.text delete 1.0 end
    catch {.messagewindow.main.text delete 1.0 end}
}

proc inspect_filteredobjectlist {{w "."}} {
    # implements Find/inspect objects...
    set ptr ""
    if {$w!="" && $w!="." && ![regexp {\.(ptr.*)-([0-9]+)} $w match ptr type]} {
        error "window name $w doesn't look like an inspector window"
    }
    filteredobjectlist_window $ptr
}

proc inspect_bypointer {} {
    # implements Inspect|By pointer...
    set pointer "ptr"
    set ok [inputbox {Inspect by pointer...} {Enter pointer (invalid pointer may cause segmentation fault!):} pointer]
    if {$ok == 1} {
        opp_inspect $pointer (default)
    }
}

proc inspect_systemmodule {} {
    # implements Inspect|Toplevel modules...
    if {[network_present] == 0} return
    opp_inspect [opp_object_systemmodule] (default)
}

proc inspect_messagequeue {} {
    # implements Inspect|Message queue...
    opp_inspect [opp_object_messagequeue] (default)
}

proc inspect_simulation {} {
    # implements Inspect|Simulation...
    opp_inspect [opp_object_simulation] (default)
}

proc inspect_componenttypes {} {
    opp_inspect [opp_object_componenttypes] {(default)}
}

proc inspect_classes {} {
    opp_inspect [opp_object_classes] {(default)}
}

proc inspect_enums {} {
    opp_inspect [opp_object_enums] {(default)}
}

proc inspect_configentries {} {
    opp_inspect [opp_object_configentries] {(default)}
}

proc inspect_functions {} {
    opp_inspect [opp_object_functions] {(default)}
}

proc simulation_options {} {
    options_dialog .
    opp_updateinspectors
}

proc save_tkenv_config {} {
    set filename "tkenv.cfg"
    set filename [tk_getSaveFile -title {Save Tkenv configuration} \
                  -defaultextension "cfg" -initialfile $filename \
                  -filetypes {{{Configuration files} {*.cfg}} {{All files} {*}}}]

    if {$filename!=""} {
       save_tkenvrc $filename 1 1 0 "# Tkenv config file"
    }
}

proc load_tkenv_config {} {
    set filename "tkenv.cfg"
    set filename [tk_getOpenFile -title {Load Tkenv configuration} \
                  -defaultextension "cfg" -initialfile $filename \
                  -filetypes {{{Configuration files} {*.cfg}} {{All files} {*}}}]

    if {$filename!=""} {
       load_tkenvrc $filename
    }
}

proc edit_textfile {} {
    # implements Options|File name...
    set types {
         {{Text files}             {*.txt}}
         {{Ini files}              {*.ini}}
         {{NED files}              {*.ned}}
         {{C++ files}              {*.cc *.cpp}}
         {{C++ headers}            {*.h}}
         {{Saved log files}        {*.out}}
         {{Output vectors}         {*.vec}}
         {{Output scalars}         {*.sca}}
         {{Snapshot files}         {*.sna}}
         {{Inspector lists}        {*.lst}}
         {{All files}              {*}}
    }
    set filename [tk_getOpenFile -title {View/Edit text file} \
                  -defaultextension "out" -initialfile "" \
                  -filetypes $types]

    if {$filename!=""} {
       create_fileviewer $filename
    }
}

proc view_inifile {} {
    set fname [opp_getfilename ini]
    if {$fname == ""} {
       messagebox {Info} "The current configuration manager doesn't use file input." info ok
       return
    }

    view_file $fname
}

proc view_outputvectorfile {} {
    set fname [opp_getfilename outvector]
    if {$fname == ""} {
       messagebox {Info} "The current output vector manager doesn't use file output." info ok
       return
    }
    if {![file exists $fname]} {
       messagebox {Info} "Output vector file not yet created (no values recorded yet)." info ok
       return
    }
    view_file $fname
}

proc view_outputscalarfile {} {
    set fname [opp_getfilename outscalar]
    if {$fname == ""} {
       messagebox {Info} "The current output scalar manager doesn't use file output." info ok
       return
    }
    if {![file exists $fname]} {
       messagebox {Info} "Output scalar file not yet created (no output scalars written)." info ok
       return
    }
    view_file $fname
}

proc view_snapshotfile {} {
    set fname [opp_getfilename snapshot]
    if {$fname == ""} {
       messagebox {Info} "The current snapshot manager doesn't use file output." info ok
       return
    }
    if {![file exists $fname]} {
       messagebox {Info} "Snapshot file not yet created (no snapshots done yet)." info ok
       return
    }
    view_file $fname
}

proc view_file {filename} {
    if [catch {open $filename r} f] {
       messagebox {Error} "Error: $f" info ok
       return
    } else {
       create_fileviewer $filename
    }
}


#
# Called when simulation speed slider on toolbar changes
#
proc animSpeedChanged {arr name op} {
    if {($op!="w" && $op!="write") || $arr!="priv" || $name!="animspeed"} {error "wrong callback"}

    global priv
    opp_setsimoption "animation_speed" $priv(animspeed)
}

