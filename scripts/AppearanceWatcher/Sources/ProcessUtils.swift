//
//  ProcessUtils.swift
//  AppearanceWatcher
//
//  Created by Whoami on 14.06.2025.
//

import Foundation
import Darwin // for sysctl, kinfo_proc



struct Process {
    let pid: pid_t
    let cmd: String
    func notify(signal: Int32) {
        kill(pid, signal)
    }
}

func listChildren(of ppid: pid_t) throws -> [Process] {
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]
    
    // 1) ask how big the buffer must be
    var size = 0
    guard sysctl(&mib, UInt32(mib.count), nil, &size, nil, 0) == 0 else {
        throw POSIXError( POSIXErrorCode(rawValue: errno) ?? .EPERM )
    }

    // 2) fetch the whole process table
    let count = size / MemoryLayout<kinfo_proc>.stride
    let procs = UnsafeMutablePointer<kinfo_proc>.allocate(capacity: count)
    defer { procs.deallocate() }

    guard sysctl(&mib, UInt32(mib.count), procs, &size, nil, 0) == 0 else {
        throw POSIXError( POSIXErrorCode(rawValue: errno) ?? .EPERM )
    }
    
    var returnArray:  [Process] = []
    
    // 3) filter by e_ppid
    for i in 0..<count {
        let k = procs[i]
        if k.kp_eproc.e_ppid == ppid {
            let cmd = withUnsafePointer(to: k.kp_proc.p_comm) {
                $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXCOMLEN)+1) {
                    String(cString: $0)
                }
            }
            //            print("PID \(k.kp_proc.p_pid)  CMD \(cmd)")
            returnArray.append(Process(pid: k.kp_proc.p_pid, cmd: cmd))
        }
    }
    
    return returnArray
}

func listChildren(of commands: [String]) throws -> [Process] {
    var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL]
    
    // 1) ask how big the buffer must be
    var size = 0
    guard sysctl(&mib, UInt32(mib.count), nil, &size, nil, 0) == 0 else {
        throw POSIXError( POSIXErrorCode(rawValue: errno) ?? .EPERM )
    }

    // 2) fetch the whole process table
    let count = size / MemoryLayout<kinfo_proc>.stride
    let procs = UnsafeMutablePointer<kinfo_proc>.allocate(capacity: count)
    defer { procs.deallocate() }

    guard sysctl(&mib, UInt32(mib.count), procs, &size, nil, 0) == 0 else {
        throw POSIXError( POSIXErrorCode(rawValue: errno) ?? .EPERM )
    }
    
    var returnArray:  [Process] = []

    // 3) filter by e_ppid
    for i in 0..<count {
        let k = procs[i]
        let cmd = withUnsafePointer(to: k.kp_proc.p_comm) {
            $0.withMemoryRebound(to: CChar.self, capacity: Int(MAXCOMLEN)+1) {
                String(cString: $0)
            }
        }
        if commands.contains(cmd) {
            returnArray.append(Process(pid: k.kp_proc.p_pid, cmd: cmd))
        }
    }
    
    return returnArray
}
