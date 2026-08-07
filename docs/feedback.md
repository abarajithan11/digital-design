# Student Feedback and Course Iteration

CSE140 is a particularly challenging course to teach and learn.
My task was to take the students from CSE 30 (C programming) to CSE 141 (Intro to computer architecture) within five weeks.
The course needed to be as rigorous as a quarter-legnth course, since it shows up in their transcript just like other courses.

I collected feedback almost daily, making adjustments to my method as the course progressed. 
I used a three-question feedback block in eight of the ten lecture activities.
Fifty-one students enrolled for the course, one discontinued early.
Each student participated in an average of 4.9 of the eight daily feedback rounds.
The final Student Evaluation of Teaching (SET) received 35 responses.

The comments below are anonymous.
They are quoted verbatim, including their original spelling and punctuation.
The students called me professor, even though I made it clear I'm just a PhD student, so I mark it `[sic]`.

## What worked especially well

The final SET reported that 97.1% of respondents agreed that course goals and expectations were communicated effectively, 97.1% agreed that sufficient opportunities for help were offered, 94.3% agreed that assessments appropriately measured the learning outcomes, and 91.4% agreed that the assignments helped them learn the content.

The strongest comments were not simply about liking the course; they described an active, supportive learning process:

> I really like the taking feedback from students and incorporating it into lectures.
> It allowed a lot of students to revisit particularly difficult topics and become more comfortable.

> Was really receptive to feedback, which kind of helped mold the way slides and information was presented.
> Also answered questions himself a lot, which made asking questions much more comfortable

> Professor [sic] Aba was just very understanding that people may be coming from different backgrounds so he starts at the basic fundamental concepts for each topic we start.

> He provided graphs and drew out graphs/examples on the chalkboard which I found to be useful.
> He also applied the material to real world examples like the FPGA, video games, and audio equipment, which I found to be very interesting and helped me feel engaged with the material.

> It was such a great learning experience, the professor [sic] really cares about our success

Students also singled out the connection between code and hardware:

> The example code alongside the theory material in the lecture slides helped me understand the concepts better and understand how a certain hardware is realized in code.

## Closing the feedback loop within the week

I read the short responses after class and used them to shape the next lecture or discussion.
These are some of the clearest request–response–result sequences in the feedback.

### June 30 → July 2

Students wrote:

> Some material feels a bit fast and there wasn't much time to take notes.

> A bit more time during the activities would be helpful.

I gave students more time for activities and worked more problems with the class.
Afterward, students wrote:

> We were given more time to do activities

> everything was well paced and so many examples to learn from doing

> I liked how we walked through each problem thoroughly

### July 9 → July 10

Students wrote:

> More examples of the fixed-point arithmetic would be helpful.

> very fast paced today, struggled to keep up

The next-day discussion recapped fixed-point arithmetic, quantization, and re-quantization through short questions and additional practice.
Afterward, students wrote:

> I think the discussion cleared up most of the topics that I was unclear during lecture.

> I learned a bit more about re-quantization, which was helpful.

### July 14 → July 16

Students wrote:

> more explanations around the code sections, they are the hardest to grasp

> More demos and animated visualizations of how the SystemVerilog translates to the different parts of the circuit (to be more visually clear what blocks of code maps to what function in the diagram)

I added a live coding and debugging segment, broke code down line by line, and continued drawing the corresponding hardware.
Afterward, students wrote:

> The live coding sessions and line-by-line breakdowns, also the state machine diagrams

> I liked the detailed notes on the systemverilog code, it made it easier to understand each part.

> the live coding was really helpful!

### July 21 → July 23

Students wrote:

> I thought the waveform activity could've used a little bit more guidance; I know I was struggling and so was the people around me for the most part.

> Maybe going a little slower on the waveform problems?

I devoted more time to manually tracing waveforms, using tables and chalkboard walkthroughs.
Afterward, students wrote:

> We spend a lot of time analyzing wave forms, so I could understand everything

> The walk through of the waveform logic was very helpful.

> I liked how we took more time to walk through the code

This loop did not make every change work for every student.
For example, some students liked the live coding, while others still found it too fast.
That mixed result is useful feedback in its own right.

## The hardest feedback and the tradeoffs behind it

### The same class felt both too slow and too fast

In the same July 9 feedback round, one student wrote:

> I think the pace should be faster.
> We spent almost 2 weeks out of 5 covering concepts already learned in prerequisite courses like CSE 30.

Another wrote:

> very fast paced today, struggled to keep up

The disagreement appeared from the beginning: “Pacing was a little slow” sat alongside requests to slow down.
I could not give every student with widely varying preparation their preferred pace.
My in-class checks showed that many students were not yet confident with the Boolean algebra, fixed-point arithmetic, or other mathematical foundations needed later in the course, so I chose not to skip those foundations.
Other students explicitly valued that choice:

> I liked how the professor [sic] didn't just assume that everyone knew the basic properties of boolean algebra and started from scratch.
> It helped make the lesson much less jarring.

The final SET made the same point from a broader perspective:

> Professor [sic] Aba was just very understanding that people may be coming from different backgrounds so he starts at the basic fundamental concepts for each topic we start.

The better future solution is not simply faster or slower.
It is a core path that establishes the prerequisites, paired with optional challenge problems for students who already know them.

### Why I did not teach SystemVerilog as if it were C or Python

One final-evaluation comment said:

> I would like to learn systemverilog as like a parallel to a programming language even though its not.
> There could be instructions that this is how you declare a function in hdl vs programming language and et cetera.
> Learn building blocks instead of patterns to modify.

This criticism identifies a real onboarding problem, but a complete programming-language-style tour was not feasible or desirable in this course.
SystemVerilog is a vastly complex, historically layered language with a dense syntax in which several constructs can describe the same hardware.
I therefore carved out a smaller subset and used consistent patterns.

I could not responsibly enumerate every legal way to drive a signal or explain the historical reasons for packed & unpacked arrays behaving so, without confusing beginners.
The part I can improve is introducing the chosen subset earlier, explaining why each restriction exists, and explicitly comparing its semantics with familiar programming languages.

## What I will improve in the next iteration

Some critical comments point to changes that should be designed into the course from the start rather than patched during a five-week term.

1. **Introduce the course's SystemVerilog subset earlier and more incrementally.**
   Students wrote, “Being thrown into the PA's with little idea of how to write Verilog; we could've started more incrementally and earlier I think” and “Not going over at least the basics of system verilog made it very hard to start assignments.”
   Since I was teaching a 10-week course in 5 weeks, the first assignment had to go live on day one. 
   In a  quarter-length course, short code-reading and code-writing exercises will begin in week one, before the first substantial programming assignment, with a recurring checklist of common synthesis and simulation mistakes.

2. **Break long explanations into shorter learn–try–check cycles.**
   One final comment said, “Explanations in class went on for almost an hour or more at times.”
   I will use shorter explanation blocks followed by an ungraded check, a worked example, or a brief peer discussion before continuing.

3. **Make live coding easier to follow and recover from.**
   Although many students praised live coding, one wrote, “The live coding session kinda had the professor just go off on his own when he started doing the pipeline.
   I was following along just fine before and then he went silent and I got lost with all the edits he was making.”
   Future live coding will use named checkpoints, downloadable snapshots, narration during every edit, and a known-working fallback if debugging consumes the segment.

4. **Make slides more useful before and after class.**
   While many students praised the visual slides showing designs and code side-by-side, some students wrote, “Slides were difficult to understand on their own” and “I hope the lecture materials can be provided earlier so that I can study them on my own in advance”.
   I will publish stable drafts earlier, simplify code slides, enlarge diagrams, and define abbreviations where they appear.
   I did create an acronym reference the day after the first lecture's feedback, but the later comment “I think the slides use a lot of abbreviations” shows that a separate glossary alone did not solve the problem.

CSE140 is a challenging course to teach and learn.
The goal is to preserve what students valued: worked examples, hardware visualizations, real applications, accessibility, and rapid response to feedback, while making the course easier to enter, easier to follow live, and easier to review independently.
