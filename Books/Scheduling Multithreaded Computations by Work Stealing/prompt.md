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

Our main contribution is a randomized work-stealing scheduling algorithm for fully strict multithreaded computations which is provably efficient in terms of time, space, and communication. We prove that the expected time to execute a fully strict computation on $P$ processors using our work-stealing scheduler is $T_1/P + O(T_\infty)$, where $T_1$ is the minimum serial execution time of the multithreaded computation and $T_\infty$ is the minimum execution time with an infinite number of processors. In addition, the space required by the execution is at most $S_1 P$, where $S_1$ is the minimum serial space requirement. These bounds are better than previous bounds for work-sharing schedulers [Blumofe and Leiserson 1998], and the work-stealing scheduler is much simpler and eminently practical. Part of this improvement is due to our focusing on fully strict computations, as compared to the (general) strict computations studied in Blumofe and Leiserson [1998]. We also prove that the expected total communication of the execution is at most $O(P T_\infty (1 + n_d) S_{\max})$, where $S_{\max}$ is the size of the largest activation record of any thread and $n_d$ is the maximum number of times that any thread synchronizes with its parent. This bound is existentially tight to within a constant factor, meeting the lower bound of Wu and Kung [1991] for communication in parallel divide-and-conquer. In contrast, work-sharing schedulers have nearly worst-case behavior for communication. Thus, our results bolster the folk wisdom that work stealing is superior to work sharing.

Others have studied and continue to study the problem of efficiently managing the space requirements of parallel computations. Culler and Arvind [1988] and Ruggiero and Sargeant [1987] give heuristics for limiting the space required by dataflow programs. Burton [1988] shows how to limit space in certain parallel computations without causing deadlock. More recently, Burton [1996] has developed and analyzed a scheduling algorithm with provably good time and space bounds. Blelloch et al.\ [1995; 1997] have also recently developed and analyzed scheduling algorithms with provably good time and space bounds. It is not yet clear whether any of these algorithms are as practical as work stealing.

The remainder of this paper is organized as follows: In Section 2, we review the graph-theoretic model of multithreaded computations introduced in Blumofe and Leiserson [1998], which provides a theoretical basis for analyzing schedulers. Section 3 gives a simple scheduling algorithm which uses a central queue. This ``busy-leaves'' algorithm forms the basis for our randomized work-stealing algorithm, which we present in Section 4. In Section 5, we introduce the atomic-access model that we use to analyze execution time and communication costs for the work-stealing algorithm, and we present and analyze a combinatorial ``balls and bins'' game that we use to derive a bound on the contention that arises in random work stealing. We then use this bound along with a delay-sequence argument [Ranade 1987] in Section 6 to analyze the execution time and communication cost of the work-stealing algorithm. To conclude, in Section 7, we briefly discuss how the theoretical ideas in this paper have been applied to the Cilk programming language and runtime system [Blumofe et al.\ 1996c; Frigo et al.\ 1998], as well as make some concluding remarks.

""




Можешь ещё раз пояснить, что значит "fully strict" задачи?
Я пишу свой thread pool для дипломной работы. Подходит ли work stealing для thread pool?



Я слышал, что в Go runtime использует как раз таки стратегию work-stealing. Но при этом там есть обмен данными между соседними потоками (не родителем). Почему они тогда использовали work-stealing?
И можно ли сказать, что если мы выбрали стратегию work-stealing и потоки обмениваются данными не только между родителями, но при этом они делают это очень редко, то эвристика такого подхода будет хорошей? Так можно рассуждать?


Правильно я понимаю o-малое и O-большое.
O(x^3) + O(x^2) = O(x^3), при x->inf
O(x^3) + O(x^2) = O(x^2), при x->0

