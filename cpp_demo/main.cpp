#include <stdio.h>
#include <thread>
#include <vector>
#include <unistd.h>
#include <sys/wait.h>
#include <stdlib.h>
using namespace std;

void PrintLineUnit(int start, int end)
{
    for (int i = start; i < end; i++)
    {
        printf("Line: %d\n", i);
    }
}

void PrintLine(int nThread)
{
    vector<thread> threads;
    for (int i = 0; i < nThread; i++)
    {
        threads.emplace_back(PrintLineUnit, i * 100, (i + 1) * 100);
    }
    for (auto &thread : threads)
    {
        if (thread.joinable())
            thread.join();
    }
}

void PrintLine_MultiProcess(int job_num)
{
    pid_t pid;
    int i;
    if (job_num <= 0)
        return;

    for (i = 0; i < job_num; i++)
    {
        pid = fork();
        if (0 == pid)
            break; // 子进程跳出循环
    }

    if (0 == pid)
    {
        // 子进程：打印自己负责的区间
        PrintLineUnit(i * 100, (i + 1) * 100);
        exit(0);
    }
    else if (pid > 0)
    {
        // 父进程：等待所有子进程结束，避免僵尸进程
        while (wait(NULL) > 0)
            ;
    }
    else
    {
        perror("fork");
        exit(1);
    }
}

int main()
{
    // PrintLine(3);
    PrintLine_MultiProcess(3);
    return 0;
}
