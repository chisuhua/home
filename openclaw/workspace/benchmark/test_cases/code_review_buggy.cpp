// ============================================================================
// 代码审查测试用例：包含竞态条件和内存泄漏的代码
// 用于 benchmark_code_quality.py - Task 2
// ============================================================================

#include <iostream>
#include <thread>
#include <vector>
#include <queue>
#include <mutex>
#include <cstring>

// 问题 1: 裸指针泄漏 - 没有 delete
class Message {
public:
    char* data;
    size_t size;
    
    Message(const char* msg, size_t len) {
        data = new char[len];  // 🔴 分配但未释放
        memcpy(data, msg, len);
        size = len;
    }
};

// 问题 2: 全局共享资源竞态
std::queue<Message*> messageQueue;  // 🔴 裸指针对列
int totalMessages = 0;  // 🔴 无保护计数器

// 问题 3: 锁保护不完整
std::mutex queueMutex;

void producer(int id) {
    for (int i = 0; i < 100; i++) {
        Message* msg = new Message("Hello", 6);
        
        // 🔴 竞态条件：检查与插入非原子
        if (messageQueue.size() < 1000) {
            messageQueue.push(msg);
            totalMessages++;  // 🔴 无锁递增
        } else {
            delete msg;  // 这里删除了，但下面的消费者可能访问已释放内存
        }
    }
}

void consumer(int id) {
    while (true) {
        Message* msg = nullptr;
        
        // 🔴 竞态条件：检查与弹出非原子
        if (!messageQueue.empty()) {
            // 🔴 两次检查之间，其他线程可能已弹出
            msg = messageQueue.front();
            messageQueue.pop();  // 🔴 可能抛出异常导致泄漏
            totalMessages--;
        }
        
        if (msg) {
            std::cout << "Consumer " << id << ": " << msg->data << std::endl;
            // 🔴 忘记 delete msg - 内存泄漏
        }
    }
}

// 问题 4: 虚析构函数缺失
class BaseTask {
public:
    virtual void execute() {
        std::cout << "BaseTask::execute()" << std::endl;
    }
    // 🔴 虚析构函数缺失 - 多态删除时泄漏
};

class DerivedTask : public BaseTask {
    int* internalData;
public:
    DerivedTask() {
        internalData = new int[1000];
    }
    
    void execute() override {
        std::cout << "DerivedTask::execute()" << std::endl;
    }
    
    // 🔴 无析构函数 - internalData 泄漏
};

// 问题 5: 死锁风险
std::mutex mutex1, mutex2;

void threadA() {
    mutex1.lock();
    std::this_thread::sleep_for(std::chrono::milliseconds(10));  // 🔴 增加死锁概率
    mutex2.lock();
    std::cout << "Thread A acquired both locks" << std::endl;
    mutex2.unlock();
    mutex1.unlock();
}

void threadB() {
    mutex2.lock();  // 🔴 与 threadA 顺序相反
    std::this_thread::sleep_for(std::chrono::milliseconds(10));
    mutex1.lock();
    std::cout << "Thread B acquired both locks" << std::endl;
    mutex1.unlock();
    mutex2.unlock();
}

int main() {
    std::vector<std::thread> producers;
    std::vector<std::thread> consumers;
    
    // 启动生产者
    for (int i = 0; i < 4; i++) {
        producers.emplace_back(producer, i);
    }
    
    // 启动消费者
    for (int i = 0; i < 4; i++) {
        consumers.emplace_back(consumer, i);
    }
    
    // 🔴 等待逻辑不完整
    for (auto& t : producers) {
        t.join();
    }
    
    // 🔴 消费者线程永不停止 - 程序不会结束
    
    return 0;
}

// ============================================================================
// 审查要点：
// 1. Message::data 从未被 delete - 每个 Message 对象泄漏 6 字节
// 2. totalMessages 竞态读写 - 可能计数错误
// 3. messageQueue 检查 - 弹出竞态 - 可能重复弹出或崩溃
// 4. BaseTask 虚析构函数缺失 - DerivedTask 多态删除时泄漏
// 5. threadA/threadB 锁顺序相反 - 经典死锁
// 6. 消费者线程无退出条件 - 程序挂起
// 7. messageQueue.pop() 可能抛出异常导致泄漏
// ============================================================================
