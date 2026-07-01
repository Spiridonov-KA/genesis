Привет!
Я читаю книгу "Scott Meyers-Effective Modern C++_ 42 Specific Ways to Improve Your Use of C++11 and C++14-O'Reilly Media (2014)"

Сделай сначала перевод. Потом сделай пояснение к тексту.

Вот текст:

""
CHAPTER 1. Deducing Types

C++98 had a single set of rules for type deduction: the one for function templates. C++11 modifies that ruleset a bit and adds two more, one for auto and one for decltype. C++14 then extends the usage contexts in which auto and decltype may be employed. The increasingly widespread application of type deduction frees you from the tyranny of spelling out types that are obvious or redundant. It makes C++ software more adaptable, because changing a type at one point in the source code automatically propagates through type deduction to other locations. However, it can render code more difficult to reason about, because the types deduced by compilers may not be as apparent as you’d like.

Without a solid understanding of how type deduction operates, effective program‐ ming in modern C++ is all but impossible. There are just too many contexts where type deduction takes place: in calls to function templates, in most situations where auto appears, in decltype expressions, and, as of C++14, where the enigmatic decltype(auto) construct is employed.

This chapter provides the information about type deduction that every C++ developer requires. It explains how template type deduction works, how auto builds on that, and how decltype goes its own way. It even explains how you can force compilers to make the results of their type deductions visible, thus enabling you to ensure that compilers are deducing the types you want them to.

""


Как переводится слово "widespread"?
