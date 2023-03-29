# ABAP OO-Task Scheduler
ABAP utility to do "CALL METHOD ... IN UPDATE TASK / STARTING NEW TASK / VIA JOB"

## Usage
Context: you have implemented your business logic inside a class `ZCL_MY_CLASS` used with an instance `o_my_object` and you'd like to refactor your methods in such a way you can start new task / update task / background job without creating Function Modules or Report, using only oo-artifacts.

+ Implement interface `ZTBOX_IF_PROCESSER` in your class `ZCL_MY_CLASS`
+ Create an object of `ZTBOX_CL_PROCESSER` passing an instance of your class

```abap
DATA(processer) = NEW ztbox_cl_processer( o_my_object ).
```

+ To execute a method in update task: call method `UPDATE_TASK` passing the name of the method

```abap
processer->update_task( 'GET_DATA_AFTER_COMMIT' ).
```

+ To execute a method in a separate task: call method `NEW_TASK` passing the name of the method

```abap
processer->new_task( 'PROCESS_DATA_NEW_SESSION' ).
```

+ To execute a method as a background job: call method `NEW_JOB` passing the name of the method

```abap
processer->new_job( 'PROCESS_DATA_BACKGROUND' ).
```

+ To perform a sequence of task-methods in such a way each task is executed only after the previous one has ended: call method `PERFORM_TASKS` passing the name of the methods forming the sequence (order is relevant)

```abap
processer->perform_tasks( VALUE #(
  ( 'CREATE_PURCHASE_ORDER' )
  ( 'CREATE_GOODS_RECEIPT' )
  ( 'CREATE_MIRO_INVOICE' ) ) ).
```

Each of these methods from `ZCL_MY_CLASS` must not have mandatory parameters.
Any initial parameters should be set as instance attributes, such as with `o_my_object->set_data( ... ).`.

If, e.g., `CREATE_PURCHASE_ORDER` method sets instance attribute `_purchase_ord_number`, its value is accessible from method `CREATE_GOODS_RECEIPT` when the sequence of tasks of the last example is performed.


## Installation
Install this project using [abapGit](https://abapgit.org/) ![abapGit](https://docs.abapgit.org/img/favicon.png)
