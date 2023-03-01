#include <windows.h>
#include <stdio.h>

int main(int argc, char* argv[])
{
    if (argc != 3)
    {
        printf("Usage: injector.exe <process_id> <dll_path>\n");
        return 1;
    }

    DWORD processId = atoi(argv[1]);

    HANDLE processHandle = OpenProcess(PROCESS_ALL_ACCESS, FALSE, processId);

    if (processHandle == NULL)
    {
        printf("Could not open process %d\n", processId);
        return 1;
    }

    LPVOID remoteString = VirtualAllocEx(processHandle, NULL, strlen(argv[2]) + 1, MEM_COMMIT, PAGE_READWRITE);

    if (remoteString == NULL)
    {
        printf("Could not allocate memory in process %d\n", processId);
        CloseHandle(processHandle);
        return 1;
    }

    if (!WriteProcessMemory(processHandle, remoteString, argv[2], strlen(argv[2]) + 1, NULL))
    {
        printf("Could not write DLL path to process %d\n", processId);
        CloseHandle(processHandle);
        VirtualFreeEx(processHandle, remoteString, 0, MEM_RELEASE);
        return 1;
    }

    LPVOID loadLibraryAddr = (LPVOID)GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA");

    if (loadLibraryAddr == NULL)
    {
        printf("Could not find LoadLibraryA in process %d\n", processId);
        CloseHandle(processHandle);
        VirtualFreeEx(processHandle, remoteString, 0, MEM_RELEASE);
        return 1;
    }

    HANDLE remoteThread = CreateRemoteThread(processHandle, NULL, 0, (LPTHREAD_START_ROUTINE)loadLibraryAddr, remoteString, 0, NULL);

    if (remoteThread == NULL)
    {
        printf("Could not create remote thread in process %d\n", processId);
        CloseHandle(processHandle);
        VirtualFreeEx(processHandle, remoteString, 0, MEM_RELEASE);
        return 1;
    }

    printf("DLL injected successfully into process %d\n", processId);

    WaitForSingleObject(remoteThread, INFINITE);
    CloseHandle(remoteThread);
    CloseHandle(processHandle);
    VirtualFreeEx(processHandle, remoteString, 0, MEM_RELEASE);

    return 0;
}
