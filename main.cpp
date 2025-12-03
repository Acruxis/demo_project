#include <iostream>
#include <stdio.h>
#include <thread>
#include <vector>
#include <string>
using namespace std;

void PrintLineUnit(int start, int end)
{
    for (int i = start; i < end; i++)
    {
        cout << "Line : " << i << endl;
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

int main()
{
    PrintLine(3);
    return 0;
}