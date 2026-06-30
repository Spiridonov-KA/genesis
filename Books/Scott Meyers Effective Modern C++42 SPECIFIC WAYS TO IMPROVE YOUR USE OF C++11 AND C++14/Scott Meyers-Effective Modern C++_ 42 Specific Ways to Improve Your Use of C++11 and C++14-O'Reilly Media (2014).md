CHAPTER 1. Deducing Types

C++98 had a single set of rules for type deduction: the one for function templates. C++11 modifies that ruleset a bit and adds two more, one for auto and one for decltype. C++14 then extends the usage contexts in which auto and decltype may be employed. The increasingly widespread application of type deduction frees you from the tyranny of spelling out types that are obvious or redundant. It makes C++ software more adaptable, because changing a type at one point in the source code automatically propagates through type deduction to other locations. However, it can render code more difficult to reason about, because the types deduced by compilers may not be as apparent as you’d like.

Without a solid understanding of how type deduction operates, effective program‐ ming in modern C++ is all but impossible. There are just too many contexts where type deduction takes place: in calls to function templates, in most situations where auto appears, in decltype expressions, and, as of C++14, where the enigmatic decltype(auto) construct is employed.

This chapter provides the information about type deduction that every C++ developer requires. It explains how template type deduction works, how auto builds on that, and how decltype goes its own way. It even explains how you can force compilers to make the results of their type deductions visible, thus enabling you to ensure that compilers are deducing the types you want them to.




Item 1: Understand template type deduction.

When users of a complex system are ignorant of how it works, yet happy with what it does, that says a lot about the design of the system. By this measure, template type deduction in C++ is a tremendous success. Millions of programmers have passed arguments to template functions with completely satisfactory results, even though many of those programmers would be hard-pressed to give more than the haziest description of how the types used by those functions were deduced.

If that group includes you, I have good news and bad news. The good news is that type deduction for templates is the basis for one of modern C++’s most compelling features: auto. If you were happy with how C++98 deduced types for templates, you’re set up to be happy with how C++11 deduces types for auto. The bad news is that when the template type deduction rules are applied in the context of auto, they sometimes seem less intuitive than when they’re applied to templates. For that reason, it’s important to truly understand the aspects of template type deduction that auto builds on. This Item covers what you need to know.

If you’re willing to overlook a pinch of pseudocode, we can think of a function template as looking like this:

```c++
template<typename T>
void f(ParamType param);
```

A call can look like this:

```c++
f(expr);    // call f with some expression
```

During compilation, compilers use expr to deduce two types: one for T and one for ParamType. These types are frequently different, because ParamType often contains adornments, e.g., const or reference qualifiers. For example, if the template is declared like this,

template<typename T>
void f(const T& param);     // ParamType is const T&

and we have this call,

int x = 0;

f(x);       // call f with an int

T is deduced to be int, but ParamType is deduced to be const int&.

It’s natural to expect that the type deduced for T is the same as the type of the argument passed to the function, i.e., that T is the type of expr. In the above example, that’s the case: x is an int, and T is deduced to be int. But it doesn’t always work that way. The type deduced for T is dependent not just on the type of expr, but also on the form of ParamType. There are three cases:

- ParamType is a pointer or reference type, but not a universal reference. (Universal references are described in Item 24. At this point, all you need to know is that they exist and that they’re not the same as lvalue references or rvalue references.)
- ParamType is a universal reference.
- ParamType is neither a pointer nor a reference.

We therefore have three type deduction scenarios to examine. Each will be based on our general form for templates and calls to it:

template<typename T>
void f(ParamType param);

f(expr);        // deduce T and ParamType from expr



Case 1: ParamType is a Reference or Pointer, but not a Universal Reference

The simplest situation is when ParamType is a reference type or a pointer type, but not a universal reference. In that case, type deduction works like this:

1. If expr’s type is a reference, ignore the reference part.
2. Then pattern-match expr’s type against ParamType to determine T.

For example, if this is our template,

template<typename T>
void f(T& param);       // param is a reference

and we have these variable declarations,

int x = 27;             // x is an int
const int cx = x;       // cx is a const int
const int& rx = x;      // rx is a reference to x as a const int

the deduced types for param and T in various calls are as follows:

f(x);           // T is int, param's type is int&

f(cx);          // T is const int,
                // param's type is const int&

f(rx);          // T is const int,
                // param's type is const int&

In the second and third calls, notice that because cx and rx designate const values, T is deduced to be const int, thus yielding a parameter type of const int&. That’s important to callers. When they pass a const object to a reference parameter, they expect that object to remain unmodifiable, i.e., for the parameter to be a reference-to-const. That’s why passing a const object to a template taking a T& parameter is safe: the constness of the object becomes part of the type deduced for T.

In the third example, note that even though rx’s type is a reference, T is deduced to be a non-reference. That’s because rx’s reference-ness is ignored during type deduction.

These examples all show lvalue reference parameters, but type deduction works exactly the same way for rvalue reference parameters. Of course, only rvalue arguments may be passed to rvalue reference parameters, but that restriction has nothing to do with type deduction.

If we change the type of f’s parameter from T& to const T&, things change a little, but not in any really surprising ways. The constness of cx and rx continues to be respected, but because we’re now assuming that param is a reference-to-const, there’s no longer a need for const to be deduced as part of T:

template<typename T>
void f(const T& param);     // param is now a ref-to-const

int x = 27;                 // as before
const int cx = x;           // as before
const int& rx = x;          // as before

f(x);                       // T is int, param's type is const int&

f(cx);                      // T is int, param's type is const int&

f(rx);                      // T is int, param's type is const int&

As before, rx’s reference-ness is ignored during type deduction.

If param were a pointer (or a pointer to const) instead of a reference, things would work essentially the same way:

template<typename T>
void f(T* param);       // param is now a pointer

int x = 27;             // as before
const int *px = &x;     // px is a ptr to x as a const int

f(&x);                  // T is int, param's type is int*

f(px);                  // T is const int,
                        // param's type is const int*


By now, you may find yourself yawning and nodding off, because C++’s type deduction rules work so naturally for reference and pointer parameters, seeing them in written form is really dull. Everything’s just obvious! Which is exactly what you want in a type deduction system.




Case 2: ParamType is a Universal Reference

Things are less obvious for templates taking universal reference parameters. Such parameters are declared like rvalue references (i.e., in a function template taking a type parameter T, a universal reference’s declared type is T&&), but they behave differently when lvalue arguments are passed in. The complete story is told in Item 24, but here’s the headline version:

- If expr is an lvalue, both T and ParamType are deduced to be lvalue references. That’s doubly unusual. First, it’s the only situation in template type deduction where T is deduced to be a reference. Second, although ParamType is declared using the syntax for an rvalue reference, its deduced type is an lvalue reference.
- If expr is an rvalue, the “normal” (i.e., Case 1) rules apply.

For example:

template<typename T>
void f(T&& param);          // param is now a universal reference

int x = 27;                 // as before
const int cx = x;           // as before
const int& rx = x;          // as before

f(x);                       // x is lvalue, so T is int&,
                            // param's type is also int&

f(cx);                      // cx is lvalue, so T is const int&,
                            // param's type is also const int&

f(rx);                      // rx is lvalue, so T is const int&,
                            // param's type is also const int&

f(27);                      // 27 is rvalue, so T is int,
                            // param's type is therefore int&&


Item 24 explains exactly why these examples play out the way they do. The key point here is that the type deduction rules for universal reference parameters are different from those for parameters that are lvalue references or rvalue references. In particular, when universal references are in use, type deduction distinguishes between lvalue arguments and rvalue arguments. That never happens for non-universal references.



Case 3: ParamType is Neither a Pointer nor a Reference

When ParamType is neither a pointer nor a reference, we’re dealing with pass-by-value:

template<typename T>
void f(T param);        // param is now passed by value

That means that param will be a copy of whatever is passed in—a completely new object. The fact that param will be a new object motivates the rules that govern how T is deduced from expr:

1. As before, if expr’s type is a reference, ignore the reference part.
2. If, after ignoring expr’s reference-ness, expr is const, ignore that, too. If it’s volatile, also ignore that. (volatile objects are uncommon. They’re generally used only for implementing device drivers. For details, see Item 40.)

Hence:

int x = 27;             // as before
const int cx = x;       // as before
const int& rx = x;      // as before


f(x);                   // T's and param's types are both int
f(cx);                  // T's and param's types are again both int
f(rx);                  // T's and param's types are still both int


Note that even though cx and rx represent const values, param isn’t const. That makes sense. param is an object that’s completely independent of cx and rx—a copy of cx or rx. The fact that cx and rx can’t be modified says nothing about whether param can be. That’s why expr’s constness (and volatileness, if any) is ignored when deducing a type for param: just because expr can’t be modified doesn’t mean that a copy of it can’t be.

It’s important to recognize that const (and volatile) is ignored only for by-value parameters. As we’ve seen, for parameters that are references-to- or pointers-to-const, the constness of expr is preserved during type deduction. But consider the case where expr is a const pointer to a const object, and expr is passed to a by-value param:

template<typename T>
void f(T param);            // param is still passed by value

const char* const ptr =     // ptr is const pointer to const object
"Fun with pointers";

f(ptr);                     // pass arg of type const char * const

Here, the const to the right of the asterisk declares ptr to be const: ptr can’t be made to point to a different location, nor can it be set to null. (The const to the left of the asterisk says that what ptr points to—the character string—is const, hence can’t be modified.) When ptr is passed to f, the bits making up the pointer are copied into param. As such, the pointer itself (ptr) will be passed by value. In accord with the type deduction rule for by-value parameters, the constness of ptr will be ignored, and the type deduced for param will be const char*, i.e., a modifiable pointer to a const character string. The constness of what ptr points to is preserved during type deduction, but the constness of ptr itself is ignored when copying it to create the new pointer, param.



Array Arguments

That pretty much covers it for mainstream template type deduction, but there’s a niche case that’s worth knowing about. It’s that array types are different from pointer types, even though they sometimes seem to be interchangeable. A primary contributor to this illusion is that, in many contexts, an array decays into a pointer to its first element. This decay is what permits code like this to compile:

const char name[] = "J. P. Briggs";     // name's type is
                                        // const char[13]

const char * ptrToName = name;          // array decays to pointer

Here, the const char* pointer ptrToName is being initialized with name, which is a const char[13]. These types (const char* and const char[13]) are not the same, but because of the array-to-pointer decay rule, the code compiles.

But what if an array is passed to a template taking a by-value parameter? What happens then?

template<typename T>
void f(T param);            // template with by-value parameter
f(name);                    // what types are deduced for T and param?

We begin with the observation that there is no such thing as a function parameter that’s an array. Yes, yes, the syntax is legal,

void myFunc(int param[]);

but the array declaration is treated as a pointer declaration, meaning that myFun could equivalently be declared like this:

void myFunc(int* param);        // same function as above

This equivalence of array and pointer parameters is a bit of foliage springing from the C roots at the base of C++, and it fosters the illusion that array and pointer types are the same.

Because array parameter declarations are treated as if they were pointer parameters, the type of an array that’s passed to a template function by value is deduced to be a pointer type. That means that in the call to the template f, its type parameter T is deduced to be const char*:

f(name);            // name is array, but T deduced as const char*

But now comes a curve ball. Although functions can’t declare parameters that are truly arrays, they can declare parameters that are references to arrays! So if we modify the template f to take its argument by reference,

template<typename T>
void f(T& param);           // template with by-reference parameter

and we pass an array to it,
f(name);                    // pass array to f

the type deduced for T is the actual type of the array! That type includes the size of the array, so in this example, T is deduced to be const char [13], and the type of f’s parameter (a reference to this array) is const char (&)[13]. Yes, the syntax looks toxic, but knowing it will score you mondo points with those few souls who care.

Interestingly, the ability to declare references to arrays enables creation of a template that deduces the number of elements that an array contains:

// return size of an array as a compile-time constant. (The
// array parameter has no name, because we care only about
// the number of elements it contains.)

template<typename T, std::size_t N>                 // see info
constexpr std::size_t arraySize(T (&)[N]) noexcept  // below on
{                                                   // constexpr
    return N;                                       // and
}                                                   // noexcept

As Item 15 explains, declaring this function constexpr makes its result available during compilation. That makes it possible to declare, say, an array with the same number of elements as a second array whose size is computed from a braced initializer:

int keyVals[] = { 1, 3, 7, 9, 11, 22, 35 };     // keyVals has
                                                // 7 elements

int mappedVals[arraySize(keyVals)];             // so does
                                                // mappedVals



Of course, as a modern C++ developer, you’d naturally prefer a std::array to a built-in array:

std::array<int, arraySize(keyVals)> mappedVals;             // mappedVals'  
                                                            // size is 7

As for arraySize being declared noexcept, that’s to help compilers generate better code. For details, see Item 14.




Function Arguments

Arrays aren’t the only things in C++ that can decay into pointers. Function types can decay into function pointers, and everything we’ve discussed regarding type deduction for arrays applies to type deduction for functions and their decay into function pointers. As a result:

void someFunc(int, double);         // someFunc is a function;
                                    // type is void(int, double)


template<typename T>
void f1(T param);                   // in f1, param passed by value

template<typename T>
void f2(T& param);                  // in f2, param passed by ref

f1(someFunc);                       // param deduced as ptr-to-func;
                                    // type is void (*)(int, double)


f2(someFunc);                       // param deduced as ref-to-func;
                                    // type is void (&)(int, double)

This rarely makes any difference in practice, but if you’re going to know about array-to-pointer decay, you might as well know about function-to-pointer decay, too.

So there you have it: the auto-related rules for template type deduction. I remarked at the outset that they’re pretty straightforward, and for the most part, they are. The special treatment accorded lvalues when deducing types for universal references muddies the water a bit, however, and the decay-to-pointer rules for arrays and functions stirs up even greater turbidity. Sometimes you simply want to grab your compilers and demand, “Tell me what type you’re deducing!” When that happens, turn to Item 4, because it’s devoted to coaxing compilers into doing just that.


Things to Remember

- During template type deduction, arguments that are references are treated as non-references, i.e., their reference-ness is ignored.
- When deducing types for universal reference parameters, lvalue arguments get special treatment.
- When deducing types for by-value parameters, const and/or volatile arguments are treated as non-const and non-volatile.
- During template type deduction, arguments that are array or function names decay to pointers, unless they’re used to initialize references.




Item 2: Understand auto type deduction.

If you’ve read Item 1 on template type deduction, you already know almost everything you need to know about auto type deduction, because, with only one curious exception, auto type deduction is template type deduction. But how can that be? Template type deduction involves templates and functions and parameters, but auto deals with none of those things.

That’s true, but it doesn’t matter. There’s a direct mapping between template type deduction and auto type deduction. There is literally an algorithmic transformation from one to the other.

In Item 1, template type deduction is explained using this general function template

template<typename T>
void f(ParamType param);

and this general call:

f(expr);                // call f with some expression

In the call to f, compilers use expr to deduce types for T and ParamType.

When a variable is declared using auto, auto plays the role of T in the template, and the type specifier for the variable acts as ParamType. This is easier to show than to describe, so consider this example:

auto x = 27;

Here, the type specifier for x is simply auto by itself. On the other hand, in this declaration,

const auto cx = x;

the type specifier is const auto. And here,

const auto& rx = x;

the type specifier is const auto&. To deduce types for x, cx, and rx in these examples, compilers act as if there were a template for each declaration as well as a call to that template with the corresponding initializing expression:

template<typename T>                // conceptual template for
void func_for_x(T param);           // deducing x's type

func_for_x(27);                     // conceptual call: param's
                                    // deduced type is x's type

template<typename T>                // conceptual template for
void func_for_cx(const T param);    // deducing cx's type

func_for_cx(x);                     // conceptual call: param's
                                    // deduced type is cx's type

template<typename T>                // conceptual template for
void func_for_rx(const T& param);   // deducing rx's type

func_for_rx(x);                     // conceptual call: param's
                                    // deduced type is rx's type


As I said, deducing types for auto is, with only one exception (which we’ll discuss soon), the same as deducing types for templates.

Item 1 divides template type deduction into three cases, based on the characteristics of ParamType, the type specifier for param in the general function template. In a variable declaration using auto, the type specifier takes the place of ParamType, so there are three cases for that, too:

- Case 1: The type specifier is a pointer or reference, but not a universal reference.
- Case 2: The type specifier is a universal reference.
- Case 3: The type specifier is neither a pointer nor a reference.

We’ve already seen examples of cases 1 and 3:

auto x = 27;            // case 3 (x is neither ptr nor reference)
const auto cx = x;      // case 3 (cx isn't either)
const auto& rx = x;     // case 1 (rx is a non-universal ref.)

Case 2 works as you’d expect:

auto&& uref1 = x;       // x is int and lvalue,
                        // so uref1's type is int&

auto&& uref2 = cx;      // cx is const int and lvalue,
                        // so uref2's type is const int&

auto&& uref3 = 27;      // 27 is int and rvalue,
                        // so uref3's type is int&&

Item 1 concludes with a discussion of how array and function names decay into pointers for non-reference type specifiers. That happens in auto type deduction, too:

const char name[] =             // name's type is const char[13]
"R. N. Briggs";

auto arr1 = name;               // arr1's type is const char*

auto& arr2 = name;              // arr2's type is
                                // const char (&)[13]

void someFunc(int, double);     // someFunc is a function;
                                // type is void(int, double)

auto func1 = someFunc;          // func1's type is
                                // void (*)(int, double)

auto& func2 = someFunc;         // func2's type is
                                // void (&)(int, double)

As you can see, auto type deduction works like template type deduction. They’re essentially two sides of the same coin.

Except for the one way they differ. We’ll start with the observation that if you want to declare an int with an initial value of 27, C++98 gives you two syntactic choices:

int x1 = 27;
int x2(27);

C++11, through its support for uniform initialization, adds these:

int x3 = { 27 };
int x4{ 27 };

All in all, four syntaxes, but only one result: an int with value 27.

But as Item 5 explains, there are advantages to declaring variables using auto instead of fixed types, so it’d be nice to replace int with auto in the above variable declarations. Straightforward textual substitution yields this code:

auto x1 = 27;
auto x2(27);
auto x3 = { 27 };
auto x4{ 27 };

These declarations all compile, but they don’t have the same meaning as the ones they replace. The first two statements do, indeed, declare a variable of type int with value 27. The second two, however, declare a variable of type std::initializer_list<int> containing a single element with value 27!

auto x1 = 27;           // type is int, value is 27
auto x2(27);            // ditto
auto x3 = { 27 };       // type is std::initializer_list<int>,
                        // value is { 27 }
auto x4{ 27 };          // ditto

This is due to a special type deduction rule for auto. When the initializer for an auto-declared variable is enclosed in braces, the deduced type is a std::initializer_list. If such a type can’t be deduced (e.g., because the values in the braced initializer are of different types), the code will be rejected:

auto x5 = { 1, 2, 3.0 };        // error! can't deduce T for
                                // std::initializer_list<T>

As the comment indicates, type deduction will fail in this case, but it’s important to recognize that there are actually two kinds of type deduction taking place. One kind stems from the use of auto: x5’s type has to be deduced. Because x5’s initializer is in braces, x5 must be deduced to be a std::initializer_list. But std::initializer_list is a template. Instantiations are std::initializer_list<T> for some type T, and that means that T’s type must also be deduced. Such deduction falls under the purview of the second kind of type deduction occurring here: template type deduction. In this example, that deduction fails, because the values in the braced initializer don’t have a single type.

The treatment of braced initializers is the only way in which auto type deduction and template type deduction differ. When an auto–declared variable is initialized with a braced initializer, the deduced type is an instantiation of std::initializer_list. But if the corresponding template is passed the same initializer, type deduction fails, and the code is rejected:

auto x = { 11, 23, 9 };             // x's type is
                                    // std::initializer_list<int>

template<typename T>                // template with parameter
void f(T param);                    // declaration equivalent to
                                    // x's declaration

f({ 11, 23, 9 });                   // error! can't deduce type for T

However, if you specify in the template that param is a std::initializer_list<T> for some unknown T, template type deduction will deduce what T is:

template<typename T>
void f(std::initializer_list<T> initList);

f({ 11, 23, 9 });               // T deduced as int, and initList's
                                // type is std::initializer_list<int>

So the only real difference between auto and template type deduction is that auto assumes that a braced initializer represents a std::initializer_list, but template type deduction doesn’t.

You might wonder why auto type deduction has a special rule for braced initializers, but template type deduction does not. I wonder this myself. Alas, I have not been able to find a convincing explanation. But the rule is the rule, and this means you must remember that if you declare a variable using auto and you initialize it with a braced initializer, the deduced type will always be std::initializer_list. It’s especially important to bear this in mind if you embrace the philosophy of uniform initialization—of enclosing initializing values in braces as a matter of course. A classic mistake in C++11 programming is accidentally declaring a std::initializer_list variable when you mean to declare something else. This pitfall is one of the reasons some developers put braces around their initializers only when they have to. (When you have to is discussed in Item 7.)

For C++11, this is the full story, but for C++14, the tale continues. C++14 permits auto to indicate that a function’s return type should be deduced (see Item 3), and C++14 lambdas may use auto in parameter declarations. However, these uses of auto employ template type deduction, not auto type deduction. So a function with an auto return type that returns a braced initializer won’t compile:

auto createInitList()
{
    return { 1, 2, 3 };         // error: can't deduce type
}                               // for { 1, 2, 3 }

The same is true when auto is used in a parameter type specification in a C++14 lambda:

std::vector<int> v;
…
auto resetV =
[&v](const auto& newValue) { v = newValue; };           // C++14
…

resetV({ 1, 2, 3 });                                    // error! can't deduce type
                                                        // for { 1, 2, 3 }


Things to Remember

- auto type deduction is usually the same as template type deduction, but auto type deduction assumes that a braced initializer represents a std::initializer_list, and template type deduction doesn’t.
- auto in a function return type or a lambda parameter implies template type deduction, not auto type deduction.







CHAPTER 4. Smart Pointers

Poets and songwriters have a thing about love. And sometimes about counting. Occasionally both. Inspired by the rather different takes on love and counting by Elizabeth Barrett Browning (“How do I love thee? Let me count the ways.”) and Paul Simon (“There must be 50 ways to leave your lover.”), we might try to enumerate the reasons why a raw pointer is hard to love:

1. Its declaration doesn’t indicate whether it points to a single object or to an array.
2. Its declaration reveals nothing about whether you should destroy what it points to when you’re done using it, i.e., if the pointer owns the thing it points to.
3. If you determine that you should destroy what the pointer points to, there’s no way to tell how. Should you use delete, or is there a different destruction mechanism (e.g., a dedicated destruction function the pointer should be passed to)?
4. If you manage to find out that delete is the way to go, Reason 1 means it may not be possible to know whether to use the single-object form (“delete”) or the array form (“delete []”). If you use the wrong form, results are undefined.
5. Assuming you ascertain that the pointer owns what it points to and you discover how to destroy it, it’s difficult to ensure that you perform the destruction exactly once along every path in your code (including those due to exceptions). Missing a path leads to resource leaks, and doing the destruction more than once leads to undefined behavior.
6. There’s typically no way to tell if the pointer dangles, i.e., points to memory that no longer holds the object the pointer is supposed to point to. Dangling pointers arise when objects are destroyed while pointers still point to them.

Raw pointers are powerful tools, to be sure, but decades of experience have demonstrated that with only the slightest lapse in concentration or discipline, these tools can turn on their ostensible masters.

Smart pointers are one way to address these issues. Smart pointers are wrappers around raw pointers that act much like the raw pointers they wrap, but that avoid many of their pitfalls. You should therefore prefer smart pointers to raw pointers. Smart pointers can do virtually everything raw pointers can, but with far fewer opportunities for error.

There are four smart pointers in C++11: std::auto_ptr, std::unique_ptr, std::shared_ptr, and std::weak_ptr. All are designed to help manage the lifetimes of dynamically allocated objects, i.e., to avoid resource leaks by ensuring that such objects are destroyed in the appropriate manner at the appropriate time (including in the event of exceptions).

std::auto_ptr is a deprecated leftover from C++98. It was an attempt to standardize what later became C++11’s std::unique_ptr. Doing the job right required move semantics, but C++98 didn’t have them. As a workaround, std::auto_ptr co-opted its copy operations for moves. This led to surprising code (copying a std::auto_ptr sets it to null!) and frustrating usage restrictions (e.g., it’s not possible to store std::auto_ptrs in containers).

std::unique_ptr does everything std::auto_ptr does, plus more. It does it as efficiently, and it does it without warping what it means to copy an object. It’s better than std::auto_ptr in every way. The only legitimate use case for std::auto_ptr is a need to compile code with C++98 compilers. Unless you have that constraint, you should replace std::auto_ptr with std::unique_ptr and never look back.

The smart pointer APIs are remarkably varied. About the only functionality common to all is default construction. Because comprehensive references for these APIs are widely available, I’ll focus my discussions on information that’s often missing from API overviews, e.g., noteworthy use cases, runtime cost analyses, etc. Mastering such information can be the difference between merely using these smart pointers and using them effectively.



Item 18: Use std::unique_ptr for exclusive-ownership resource management.

When you reach for a smart pointer, std::unique_ptr should generally be the one closest at hand. It’s reasonable to assume that, by default, std::unique_ptrs are the same size as raw pointers, and for most operations (including dereferencing), they execute exactly the same instructions. This means you can use them even in situations where memory and cycles are tight. If a raw pointer is small enough and fast enough for you, a std::unique_ptr almost certainly is, too.

std::unique_ptr embodies exclusive ownership semantics. A non-null std::unique_ptr always owns what it points to. Moving a std::unique_ptr transfers ownership from the source pointer to the destination pointer. (The source pointer is set to null.) Copying a std::unique_ptr isn’t allowed, because if you could copy a std::unique_ptr, you’d end up with two std::unique_ptrs to the same resource, each thinking it owned (and should therefore destroy) that resource. std::unique_ptr is thus a move-only type. Upon destruction, a non-null std::unique_ptr destroys its resource. By default, resource destruction is accomplished by applying delete to the raw pointer inside the std::unique_ptr.

A common use for std::unique_ptr is as a factory function return type for objects in a hierarchy. Suppose we have a hierarchy for types of investments (e.g., stocks, bonds, real estate, etc.) with a base class Investment.

class Investment { … };

class Stock:
public Investment { … };

class Bond:
public Investment { … };

class RealEstate:
public Investment { … };

A factory function for such a hierarchy typically allocates an object on the heap and returns a pointer to it, with the caller being responsible for deleting the object when it’s no longer needed. That’s a perfect match for std::unique_ptr, because the caller acquires responsibility for the resource returned by the factory (i.e., exclusive ownership of it), and the std::unique_ptr automatically deletes what it points to when the std::unique_ptr is destroyed. A factory function for the Investment hierarchy could be declared like this:

template<typename... Ts>        // return std::unique_ptr
std::unique_ptr<Investment>     // to an object created
makeInvestment(Ts&&... params); // from the given args

Callers could use the returned std::unique_ptr in a single scope as follows,
{
    …
    auto pInvestment =                  // pInvestment is of type
        makeInvestment( arguments );    // std::unique_ptr<Investment>
    …
}                                       // destroy *pInvestment

but they could also use it in ownership-migration scenarios, such as when the std::unique_ptr returned from the factory is moved into a container, the container element is subsequently moved into a data member of an object, and that object is later destroyed. When that happens, the object’s std::unique_ptr data member would also be destroyed, and its destruction would cause the resource returned from the factory to be destroyed. If the ownership chain got interrupted due to an exception or other atypical control flow (e.g., early function return or break from a loop), the std::unique_ptr owning the managed resource would eventually have its destructor called (There are a few exceptions to this rule. Most stem from abnormal program termination. If an exception propagates out of a thread’s primary function (e.g., main, for the program’s initial thread) or if a noexcept specification is violated (see Item 14), local objects may not be destroyed, and if std::abort or an exit function (i.e., std::_Exit, std::exit, or std::quick_exit) is called, they definitely won’t be.), and the resource it was managing would thereby be destroyed.

By default, that destruction would take place via delete, but, during construction, std::unique_ptr objects can be configured to use custom deleters: arbitrary functions (or function objects, including those arising from lambda expressions) to be invoked when it’s time for their resources to be destroyed. If the object created by makeInvestment shouldn’t be directly deleted, but instead should first have a log entry written, makeInvestment could be implemented as follows. (An explanation follows the code, so don’t worry if you see something whose motivation is less than obvious.)

auto delInvmt = [](Investment* pInvestment)     // custom
    {                                           // deleter
        makeLogEntry(pInvestment);              // (a lambda
        delete pInvestment;                     // expression)
    };  

template<typename... Ts>                            // revised
std::unique_ptr<Investment, decltype(delInvmt)>     // return type
makeInvestment(Ts&&... params)
{
    std::unique_ptr<Investment, decltype(delInvmt)> // ptr to be
    pInv(nullptr, delInvmt);                        // returned
    if ( /* a Stock object should be created */ )
    {
        pInv.reset(new Stock(std::forward<Ts>(params)...));
    }
    else if ( /* a Bond object should be created */ )
    {
        pInv.reset(new Bond(std::forward<Ts>(params)...));
    }
    else if ( /* a RealEstate object should be created */ )
    {
        pInv.reset(new RealEstate(std::forward<Ts>(params)...));
    }

    return pInv;
}

In a moment, I’ll explain how this works, but first consider how things look if you’re a caller. Assuming you store the result of the makeInvestment call in an auto variable, you frolic in blissful ignorance of the fact that the resource you’re using requires special treatment during deletion. In fact, you veritably bathe in bliss, because the use of std::unique_ptr means you need not concern yourself with when the resource should be destroyed, much less ensure that the destruction happens exactly once along every path through the program. std::unique_ptr takes care of all those things automatically. From a client’s perspective, makeInvestment’s interface is sweet.

The implementation is pretty nice, too, once you understand the following:

- delInvmt is the custom deleter for the object returned from makeInvestment. All custom deletion functions accept a raw pointer to the object to be destroyed, then do what is necessary to destroy that object. In this case, the action is to call makeLogEntry and then apply delete. Using a lambda expression to create delInvmt is convenient, but, as we’ll see shortly, it’s also more efficient than writing a conventional function.

- When a custom deleter is to be used, its type must be specified as the second type argument to std::unique_ptr. In this case, that’s the type of delInvmt, and that’s why the return type of makeInvestment is std::unique_ptr<Investment, decltype(delInvmt)>. (For information about decltype, see Item 3.)

- The basic strategy of makeInvestment is to create a null std::unique_ptr, make it point to an object of the appropriate type, and then return it. To associate the custom deleter delInvmt with pInv, we pass that as its second constructor argument.

- Attempting to assign a raw pointer (e.g., from new) to a std::unique_ptr won’t compile, because it would constitute an implicit conversion from a raw to a smart pointer. Such implicit conversions can be problematic, so C++11’s smart pointers prohibit them. That’s why reset is used to have pInv assume ownership of the object created via new.

- With each use of new, we use std::forward to perfect-forward the arguments passed to makeInvestment (see Item 25). This makes all the information provided by callers available to the constructors of the objects being created.

- The custom deleter takes a parameter of type Investment*. Regardless of the actual type of object created inside makeInvestment (i.e., Stock, Bond, or RealEstate), it will ultimately be deleted inside the lambda expression as an Investment* object. This means we’ll be deleting a derived class object via a base class pointer. For that to work, the base class—Investment—must have a virtual destructor:

class Investment {
public:
    …                                       // essential
    virtual ~Investment();                  // design
    …                                       // component!
};

In C++14, the existence of function return type deduction (see Item 3) means that makeInvestment could be implemented in this simpler and more encapsulated fashion:

```
template<typename... Ts>
auto makeInvestment(Ts&&... params)             // C++14
{
 auto delInvmt = [](Investment* pInvestment)    // this is now
 {                                              // inside
            makeLogEntry(pInvestment);          // make-
            delete pInvestment;                 // Investment
 };

 std::unique_ptr<Investment, decltype(delInvmt)> // as
    pInv(nullptr, delInvmt);                     // before

 if ( … )                                       // as before
 {
    pInv.reset(new Stock(std::forward<Ts>(params)...));
 }
 else if ( … )                                  // as before
 {
    pInv.reset(new Bond(std::forward<Ts>(params)...));
 }
 else if ( … )                                  // as before
 {
    pInv.reset(new RealEstate(std::forward<Ts>(params)...));
 }
 return pInv; // as before
}
```

I remarked earlier that, when using the default deleter (i.e., delete), you can reasonably assume that std::unique\_ptr objects are the same size as raw pointers. When custom deleters enter the picture, this may no longer be the case. Deleters that are function pointers generally cause the size of a std::unique\_ptr to grow from one word to two. For deleters that are function objects, the change in size depends on how much state is stored in the function object. Stateless function objects (e.g., from lambda expressions with no captures) incur no size penalty, and this means that when a custom deleter can be implemented as either a function or a captureless lambda expression, the lambda is preferable:

```
auto delInvmt1 = [](Investment* pInvestment) // custom
        {                                   // deleter
            makeLogEntry(pInvestment);      // as
            delete pInvestment;             // stateless
        };                                  // lambda
template<typename... Ts> // return type
std::unique_ptr<Investment, decltype(delInvmt1)> // has size of
makeInvestment(Ts&&... args); // Investment*
void delInvmt2(Investment* pInvestment) // custom
{ // deleter
 makeLogEntry(pInvestment); // as function
 delete pInvestment;
}
template<typename... Ts> // return type has
std::unique_ptr<Investment, // size of Investment*
 void (*)(Investment*)> // plus at least size
makeInvestment(Ts&&... params); // of function pointer!
```

Function object deleters with extensive state can yield std::unique\_ptr objects of significant size. If you find that a custom deleter makes your std::unique\_ptrs unacceptably large, you probably need to change your design.

Factory functions are not the only common use case for std::unique\_ptrs. They're even more popular as a mechanism for implementing the Pimpl Idiom. The code for that isn't complicated, but in some cases it's less than straightforward, so I'll refer you to [Item 22](#page-164-0), which is dedicated to the topic.

std::unique\_ptr comes in two forms, one for individual objects (std::unique\_ptr<T>) and one for arrays (std::unique\_ptr<T[]>). As a result, there's never any ambiguity about what kind of entity a std::unique\_ptr points to. The std::unique\_ptr API is designed to match the form you're using. For example, there's no indexing operator (operator[]) for the single-object form, while the array form lacks dereferencing operators (operator\* and operator->).

The existence of std::unique\_ptr for arrays should be of only intellectual interest to you, because std::array, std::vector, and std::string are virtually always better data structure choices than raw arrays. About the only situation I can conceive of when a std::unique\_ptr<T[]> would make sense would be when you're using a C-like API that returns a raw pointer to a heap array that you assume ownership of.

std::unique\_ptr is the C++11 way to express exclusive ownership, but one of its most attractive features is that it easily and efficiently converts to a std::shared\_ptr:

```
std::shared_ptr<Investment> sp = // converts std::unique_ptr
 makeInvestment( arguments ); // to std::shared_ptr
```

This is a key part of why std::unique\_ptr is so well suited as a factory function return type. Factory functions can't know whether callers will want to use exclusive-ownership semantics for the object they return or whether shared ownership (i.e., std::shared\_ptr) would be more appropriate. By returning a std::unique\_ptr, factories provide callers with the most efficient smart pointer, but they don't hinder callers from replacing it with its more flexible sibling. (For information about std::shared\_ptr, proceed to Item 19.

## **Things to Remember**

- std::unique\_ptr is a small, fast, move-only smart pointer for managing resources with exclusive-ownership semantics.
- By default, resource destruction takes place via delete, but custom deleters can be specified. Stateful deleters and function pointers as deleters increase the size of std::unique\_ptr objects.
- Converting a std::unique\_ptr to a std::shared\_ptr is easy.



Item 19: Use std::shared\_ptr for shared-ownership resource management.

Programmers using languages with garbage collection point and laugh at what C++ programmers go through to prevent resource leaks. "How primitive!" they jeer. "Didn't you get the memo from Lisp in the 1960s? Machines should manage resource lifetimes, not humans." C++ developers roll their eyes. "You mean the memo where the only resource is memory and the timing of resource reclamation is nondeterministic? We prefer the generality and predictability of destructors, thank you." But our bravado is part bluster. Garbage collection really is convenient, and manual lifetime management really can seem akin to constructing a mnemonic memory circuit using stone knives and bear skins. Why can't we have the best of both worlds: a system that works automatically (like garbage collection), yet applies to all resources and has predictable timing (like destructors)?

std::shared\_ptr is the C++11 way of binding these worlds together. An object accessed via std::shared\_ptrs has its lifetime managed by those pointers through *shared ownership*. No specific std::shared\_ptr owns the object. Instead, all std::shared\_ptrs pointing to it collaborate to ensure its destruction at the point where it's no longer needed. When the last std::shared\_ptr pointing to an object stops pointing there (e.g., because the std::shared\_ptr is destroyed or made to point to a different object), that std::shared\_ptr destroys the object it points to. As with garbage collection, clients need not concern themselves with managing the lifetime of pointed-to objects, but as with destructors, the timing of the objects' destruction is deterministic.

A std::shared\_ptr can tell whether it's the last one pointing to a resource by consulting the resource's *reference count*, a value associated with the resource that keeps track of how many std::shared\_ptrs point to it. std::shared\_ptr constructors increment this count (usually—see below), std::shared\_ptr destructors decrement it, and copy assignment operators do both. (If sp1 and sp2 are std::shared\_ptrs to different objects, the assignment "sp1 = sp2;" modifies sp1 such that it points to the object pointed to by sp2. The net effect of the assignment is that the reference count for the object originally pointed to by sp1 is decremented, while that for the object pointed to by sp2 is incremented.) If a std::shared\_ptr sees a reference count of zero after performing a decrement, no more std::shared\_ptrs point to the resource, so the std::shared\_ptr destroys it.

The existence of the reference count has performance implications: