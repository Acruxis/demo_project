#include <iostream>
#include <stdio.h>
#include <thread>
#include <vector>
#include <string>
#include <unistd.h>
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
    pid_t ppid, pid;
    int i;
    for (i = 0; i < job_num; i++)
    {
        pid = fork();
        if (0 == pid)
            break;
    }
    if (pid > 0)
    {
        // parent
    }
    else if (0 == pid)
    {
        // child
        PrintLineUnit(i * 100, (i + 1) * 100);

        exit(0);
    }
    else
    {
        exit(0);
    }
    while (true)
        ;
}

int main()
{
    int history_id = 102210;
    cout << history_id << ", size_of int : " << sizeof(int) << endl;
    // PrintLine(3);
    PrintLine_MultiProcess(3);
    return 0;
}