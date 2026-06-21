Привет!
Я читаю статью "Scheduling Multithreaded Computations by Work Stealing" Robert D. Blumofe и Charles E. Leiserson.
Помоги разобраться.
Сделай сначала перевод. Потом сделай к нему пояснения.
Вот текст:

""

\section{Introduction}
For efficient execution of a dynamically growing ``multithreaded'' computation on a MIMD-style parallel computer, a scheduling algorithm must ensure that enough threads are active concurrently to keep the processors busy. Simultaneously, it should ensure that the number of concurrently active threads remains within reasonable limits so that memory requirements are not unduly large. Moreover, the scheduler should also try to maintain related threads on the same processor, if possible, so that communication between them can be minimized. Needless to say, achieving all these goals simultaneously can be difficult.

Two scheduling paradigms have arisen to address the problem of scheduling multithreaded computations: work sharing and work stealing. In work sharing, whenever a processor generates new threads, the scheduler attempts to migrate some of them to other processors in hopes of distributing the work to underutilized processors. In work stealing, however, underutilized processors take the initiative: they attempt to ``steal'' threads from other processors. Intuitively, the migration of threads occurs less frequently with work stealing than with work sharing, since when all processors have work to do, no threads are migrated by a work-stealing scheduler, but threads are always migrated by a work-sharing scheduler.

The work-stealing idea dates back at least as far as Burton and Sleep's [1981] research on parallel execution of functional programs and Halstead's [1984] implementation of Multilisp. These authors point out the heuristic benefits of work stealing with regards to space and communication. Since then, many researchers have implemented variants on this strategy.\footnote{See, for example, Blumofe and Lisiecki [1997], Feldmann et al.\ [1993], Finkel and Manber [1987], Halbherr et al.\ [1994], Kuszmaul [1994], Mohr et al.\ [1991], and Vandevoorde and Roberts [1988].} Rudolph et al.\ [1991] analyzed a randomized work-stealing strategy for load balancing independent jobs on a parallel computer, and Karp and Zhang [1993] analyzed a randomized work-stealing strategy for parallel backtrack search. Zhang and Ortynski [1994] have obtained good bounds on the communication requirements of this algorithm.

In this paper, we present and analyze a work-stealing algorithm for scheduling ``fully strict'' (well-structured) multithreaded computations. This class of computations encompasses both backtrack search computations [Karp and Zhang 1993; Zhang and Ortynski 1994] and divide-and-conquer computations [Wu and Kung 1991], as well as dataflow computations [Arvind et al.\ 1989] in which threads may stall due to a data dependency. We analyze our algorithms in a stringent atomic-access model similar to the atomic message-passing model of Liu et al.\ [1993] in which concurrent accesses to the same data structure are serially queued by an adversary.

""


Я дальше читаю статью "Scheduling Multithreaded Computations by Work Stealing" Robert D. Blumofe и Charles E. Leiserson.
Помоги разобраться.
Сделай сначала перевод. Потом сделай к нему пояснения.
Вот текст:

""

\section{A Model of Multithreaded Computation}
This section reprises the graph-theoretic model of multithreaded computation introduced in Blumofe and Leiserson [1998]. We also define what it means for computations to be ``fully strict.'' We conclude with a statement of the greedy-scheduling theorem, which is an adaptation of theorems by Brent [1974] and Graham [1966; 1969] on dag scheduling.

\begin{figure}[h]
\centering
\includegraphics[width=0.9\textwidth]{/home/spiridonov-kirill/Documents/genesis/Books/Scheduling Multithreaded Computations by Work Stealing/img/fig_1.png}
\caption{A multithreaded computation. This computation contains 23 instructions $v_1, v_2, \dots, v_{23}$ and 6 threads $\Gamma_1, \Gamma_2, \dots, \Gamma_6$.}
\end{figure}

A multithreaded computation is composed of a set of threads, each of which is a sequential ordering of unit-time instructions. The instructions are connected by dependency edges, which provide a partial ordering on which instructions must execute before which other instructions. In Figure~1, for example, each shaded block is a thread with circles representing instructions and the horizontal edges, called continue edges, representing the sequential ordering. Thread $T_5$ of this example contains 3 instructions: $v_{10}$, $v_{11}$, and $v_{12}$. The instructions of a thread must execute in this sequential order from the first (leftmost) instruction to the last (rightmost) instruction. In order to execute a thread, we allocate for it a chunk of memory, called an activation frame, that the instructions of the thread can use to store the values on which they compute.

""




Можешь ещё раз пояснить, что значит "fully strict" задачи?
Я пишу свой thread pool для дипломной работы. Подходит ли work stealing для thread pool?



Я слышал, что в Go runtime использует как раз таки стратегию work-stealing. Но при этом там есть обмен данными между соседними потоками (не родителем). Почему они тогда использовали work-stealing?
И можно ли сказать, что если мы выбрали стратегию work-stealing и потоки обмениваются данными не только между родителями, но при этом они делают это очень редко, то эвристика такого подхода будет хорошей? Так можно рассуждать?


Правильно я понимаю o-малое и O-большое.
O(x^3) + O(x^2) = O(x^3), при x->inf
O(x^3) + O(x^2) = O(x^2), при x->0


Как переводится слово "serial"?



Можешь рассказать про этот момент поподробнее:

""
In addition, the space required by the execution is at most $S_1 P$, where $S_1$ is the minimum serial space requirement. These bounds are better than previous bounds for work-sharing schedulers [Blumofe and Leiserson 1998], and the work-stealing scheduler is much simpler and eminently practical.
""

Правильно я понял это оценка говорит о том, что сам алгоритм потребляет какую-то константную память, которая не увеличивает общую потребляемую память асимптотически. Так?


Давай ещё раз. эта оценка $S_1 P$ говорит нам о том, что память программы S асимптотически такая $S_1 P$. Так?

Т.е. правильно я понял, что при стратегии work-sharing, когда мы складываем задачи в глобальную очередь у нас оценка $S \le S_1 P$ может не выполняться, потому что задачи делаются отложенными и в случае вычисления последовательности фибоначи каждая задачу будет порождать ещё две, а вычисление будет откладываться. Так?

Расскажи про вот это поподробнее:
""
We prove that the expected time to execute a fully strict computation on $P$ processors using our work-stealing scheduler is $T_1/P + O(T_\infty)$, where $T_1$ is the minimum serial execution time of the multithreaded computation and $T_\infty$ is the minimum execution time with an infinite number of processors
""

Что значит, что $T_1$ - это минимальное время выполнение последовательного выполнения? Что такое максимальное? Откуда взялось минимальное?


Правильно я понял, что $T_\infty$ - это длина, время критического пути при выполнении программы на бесконечном числе потоков. И смысл этой величины в том, что вся наша программа не может выполнится быстрее $T_\infty$, потому что некоторые задачи B должны дождаться сначала выполнения задачи A и задачи B нельзя поставить на выполнение, пока не выполнится A. Я правильно понимаю?

