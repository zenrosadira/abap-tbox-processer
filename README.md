# ABAP OO-Task Scheduler
ABAP utility to do "CALL METHOD ... IN UPDATE TASK / STARTING NEW TASK / VIA JOB"

## Usage
Context: you have implemented your business logic inside a class `ZCL_MY_CLASS` used with an instance `o_my_object` and you'd like to refactor your methods in such a way you can start new task / update task / background job without creating Function Modules or Report, using only oo-artifacts.

+ Implement interface ZTBOX_IF_PROCESSER
+ Create an object of ZTBOX_CL_PROCESSER passing an instance of your class
```
DATA(processer) = NEW ztbox_cl_processer( o_my_object ).
```
+ To execute a method in update task: call method UPDATE_TASK passing the name of the method
```
processer->update_task( 'GET_DATA_AFTER_COMMIT' ).
```
+ To execute a method in a separate task: call method NEW_TASK passing the name of the method
```
processer->new_task( 'PROCESS_DATA_NEW_SESSION' ).
```
+ To execute a method as a background job: call method NEW_JOB passing the name of the method
```
processer->new_task( 'PROCESS_DATA_BACKGROUND' ).
```
+ To perform a sequence of task-methods in such a way each task is executed only after the previous one has ended: call method PERFORM_TASKS passing the name of the methods forming the sequence (order is relevant)
```
processer->perform_tasks( VALUE #(
  ( 'CREATE_PURCHASE_ORDER' )
  ( 'CREATE_GOODS_RECEIPT' )
  ( 'CREATE_MIRO_INVOICE' ) ) ).
```

## Installation
Install this project using [abapGit](https://abapgit.org/) ![abapGit](https://docs.abapgit.org/img/favicon.png)
