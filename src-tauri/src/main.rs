// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]
#![allow(nonstandard_style)]
#![allow(unused_imports)]

use std::sync::{
    Mutex, OnceLock
};
use sysinfo::{
    Components, Disks, Networks, System, ProcessRefreshKind, DiskKind
};
use cache_size::{
    l1_cache_size,
    l2_cache_size,
    l3_cache_size
};

static sysLockMutex: Mutex<Option<System>> = Mutex::new(None);

// Learn more about Tauri commands at https://tauri.app/v1/guides/features/command
#[tauri::command]
fn getCPUArch() -> String {
    match System::cpu_arch() {
        Some(arch) => {
            return format!("{}", arch);
        },
        None => {
            return format!("{}", ""); // unreachable
        }
    }
}

#[tauri::command]
fn getTotalMemory() -> u64 {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.total_memory();
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getUsedMemory() -> u64 {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.used_memory();
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getTotalSwap() -> u64 {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.total_swap();
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getUsedSwap() -> u64 {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.used_swap();
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getLogicalCoreCount() -> usize {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.cpus().len();
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getPhysicalCoreCount() -> usize {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            match sys.physical_core_count() {
                Some(count) => {
                    return count;
                },
                None => {
                    return 0; // unreachable
                }
            }
        },
        None => {
            return 0; // unreachable
        }
    }
}

#[tauri::command]
fn getCoresUsages() -> Vec<f32> {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            let cpus = sys.cpus();
            let mut usages = vec![0.0; cpus.len()]; // ten zeroes
            let mut i: usize = 0;
            for cpu in cpus {
                usages[i] = cpu.cpu_usage();
                i += 1;
            }
            return usages;
        },
        None => {
            return vec![0.0]; // unreachable
        }
    }
}

#[tauri::command]
fn getCoresFrequencies() -> Vec<u64> {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            let cpus = sys.cpus();
            let mut usages = vec![0; cpus.len()]; // ten zeroes
            let mut i: usize = 0;
            for cpu in cpus {
                usages[i] = cpu.frequency();
                i += 1;
            }
            return usages;
        },
        None => {
            return vec![0]; // unreachable
        }
    }
}

#[tauri::command]
fn refreshData() {
    let mut mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_mut() {
        Some(sys) => {
            sys.refresh_cpu();
            sys.refresh_memory();
            sys.refresh_processes_specifics(ProcessRefreshKind::new());
        },
        None => {}
    }
}

#[tauri::command]
fn getCPUName() -> String {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return format!("{}", sys.cpus()[0].brand());
        },
        None => {
            return format!("{}", "Unknown CPU"); // unreachable
        }
    }
}

#[tauri::command]
fn getLCacheSizes() -> Vec<usize> {
    let mut sizes = vec![0; 3];
    match l1_cache_size() {
        Some(sz) => {
            sizes[0] = sz;
        },
        None => {}
    }
    match l2_cache_size() {
        Some(sz) => {
            sizes[1] = sz;
        },
        None => {}
    }
    match l3_cache_size() {
        Some(sz) => {
            sizes[2] = sz;
        },
        None => {}
    }
    return sizes;
}

#[tauri::command]
fn getProcessesCount() -> usize {
    let mutex_changer = sysLockMutex.lock().unwrap();
    match mutex_changer.as_ref() {
        Some(sys) => {
            return sys.processes().len();
        },
        None => {
            return 0; // unreachable
        }
    }
}

// #[tauri::command]
// fn getProcesses() -> Vec<String> {
//     let mutex_changer = sysLockMutex.lock().unwrap();
//     match mutex_changer.as_ref() {
//         Some(sys) => {
//             let processes = sys.processes();
//             let mut processDatas: Vec<Vec<String>> = Vec::with_capacity(processes.len());
//             for process in processes {
//                 let name = format!("{}", process.name());
//                 let cmd = format!("{}", process.cmd());
//                 let id = format!("{}", process.pid().as_u32());
//                 let serializedProcess = vec![id];
//                 processDatas.push(serializedProcess);
//             }
//         },
//         None => {
//             return vec![format!("{}", ""); 0]; // unreachable
//         }
//     }
// }

#[tauri::command]
fn getDisks() -> Vec<Vec<String>> {
    let disks = Disks::new_with_refreshed_list();
    let disksList = disks.list();
    let mut diskDatas: Vec<Vec<String>> = Vec::with_capacity(disksList.len());
    for disk in disksList {
        let kind = match disk.kind() {
            DiskKind::HDD => format!("{}", 1),
            DiskKind::SSD => format!("{}", 2),
            _ => format!("{}", 0)
        };
        let name = match disk.name().to_str() {
            Some(res) => format!("{}", res),
            None => format!("{}", ""),
        };
        let fileSystem = match disk.file_system().to_str() {
            Some(res) => format!("{}", res),
            None => format!("{}", ""),
        };
        let totalSpace = format!("{}", disk.total_space());
        let availableSpace = format!("{}", disk.available_space());
        let mountPoint = match disk.mount_point().to_str() {
            Some(pathStr) => format!("{}", pathStr),
            None => format!("{}", "") // unreachable
        };
        let serializedDisk = vec![kind, name, fileSystem, totalSpace, availableSpace, mountPoint];
        diskDatas.push(serializedDisk);
    }
    return diskDatas;
}

#[tauri::command]
fn getSystemUptime() -> u64 {
    return System::uptime();
}




fn main() {
    let mut mutex_changer = sysLockMutex.lock().unwrap();
    *mutex_changer = Some(System::new_all());
    match mutex_changer.as_mut() {
        Some(sys) => {
            sys.refresh_all();
        },
        None => {},
    }
    std::mem::drop(mutex_changer);

    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            getCPUArch,
            getTotalMemory,
            getUsedMemory,
            getTotalSwap,
            getUsedSwap,
            getLogicalCoreCount,
            getPhysicalCoreCount,
            getCoresUsages,
            getCoresFrequencies,
            getCPUName,
            refreshData,
            getProcessesCount,
            getDisks,
            getSystemUptime,
            getLCacheSizes
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
