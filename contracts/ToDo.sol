// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract ToDo {
    
    event TaskCreated(uint256 id, uint256 date, string content, bool done);

    event TaskCompleted(uint256 id, uint256 dateComplete);

    event TaskDeleted(uint256 id);
    
    struct Task {
        uint256 id;
        uint256 date;
        string content;
        bool done;
        uint256 dateComplete;
    }

    address owner;

    mapping(uint256 => Task) private tasks;

    uint256 private taskCounter = 1;
    
    uint256[] private taskIds;
    
    constructor() {
        owner = msg.sender;
    }
    
    function createTask(string memory _content) public returns(uint256) {
        uint256 theNow = block.timestamp;
        uint256 id = taskCounter;

        tasks[id] = Task(id, theNow, _content, false, 0);
        taskIds.push(id);

        emit TaskCreated(id, theNow, _content, false);
        taskCounter++;
        return id;
    }

    function getTaskIds() external view returns (uint256[] memory) {
        return taskIds;
    }
    
    function getTask(uint256 id) external view returns(Task memory) {
        return tasks[id];
    }

    function getTasks() external view returns (Task[] memory) {
        Task[] memory _tasks = new Task[](taskIds.length);
        for (uint256 i = 0; i < taskIds.length; i++) {
            if (taskIds[i] != 0) {
                _tasks[i] = tasks[taskIds[i]];
            }
        }
        return _tasks;
    }

    function completeTask(uint256 id) external taskExists(id) onlyOwner {
        Task storage task = tasks[id];
        require(task.done == false, "Task already completed");
        task.done = true;
        task.dateComplete = block.timestamp;

        emit TaskCompleted(id, task.dateComplete);
    }
    
    function deleteTask(uint256 id) external taskExists(id) onlyOwner {
        delete tasks[id];

        for (uint256 i = 0; i < taskIds.length; i++) {
            if (taskIds[i] == id) {
                delete taskIds[i];
                break;
            }
        }

        emit TaskDeleted(id);
    }

    modifier taskExists(uint256 id) {
        if (tasks[id].id == 0) {
            revert("Revert: taskId not found");
        }
        _;
    }
    
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
}
