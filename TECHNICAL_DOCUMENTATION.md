# Technical Documentation

## 1. Data Structure 
The `Exam_Reader` is responsible for parsing multiple-choice exams into the data structure outlined below. For each loaded file, an `Exam_Reader` object is created, containing the following data, which is stored in a hashmap.

As a data structure, this is quite extensive. Some might argue that it uses a lot of memory and that the purpose of `Exam_Reader` could be achieved with less data.

I agree with that point; however, I chose this data structure so that an `Exam_Reader` object can be used for both the `Exam_Randomizer` and the `Exam_Scorer`. If I had used a different object for the `Exam_Scorer` than for the `Exam_Randomizer`, I would have had to write methods twice, which would lead to code redundancy.

Another advantage of using such a large data structure is that it simplifies querying. For example, for the `Exam_Randomizer`, I could easily query the corresponding line from `Exam_Reader` and write it to the output file without worrying about spaces, etc. To compare two exams, I used the normalized version of questions and answers. To neatly print these to the console, I retrieved their pretty versions.


```    
class               => "Exam_Reader",
filename            => "t/Test_Exam.txt",
layouts             => [
                        "Complete this exam by placing an 'X' in the box beside each correct\nanswer, like so:\n\n    [ ] This is not the correct answer\n    [ ] This is not the correct answer either\n    [ ] This is an incorrect answer\n    [X] This is the correct answer\n    [ ] This is an irrelevant answer\n\nScoring: Each question is worth 2 points.\n         Final score will be: SUM / 10\n\nWarning: Each question has only one correct answer. Answers to\n         questions for which two or more boxes are marked with an 'X'\n         will be scored as zero.\n\n",
                        "________________________________________________________________________________\n\nQ\nA\n",
                        "________________________________________________________________________________\n\n\nQ\nA\n",
                        "________________________________________________________________________________\n\n\nQ\nA\n",
                        "________________________________________________________________________________\n\n\nQ\nA\n",
                        "________________________________________________________________________________\n\n\nQ\nA\n\n\n",
                        "================================================================================\n                                  END OF EXAM\n================================================================================\n",
                        ],
questions           => [
                        "door:",
                        "capital center switzerland is:",
                        "today date:",
                        "cats like:",
                        "meaning life?",
                        ],
all_norm_answers    => {
                        "capital center switzerland is:" => ["bern", "zuerich", "basel", "berlin", "biel"],
                        "cats like:" => ["treated kindly","eat cat food","walk outdoor woods","dogs calm","humans feed",],
                        "door:" => ["open", "closed", "covered blood", "covered water", "locked"],
                        "meaning life?" => ["work till die","enjoy sunlight","walk great miles","study computer science","cry day",],
                        "today date:" => ["jump water","eat sandwich","put glasses","delete computer","throw away computer",],
                        },                        
marked_norm_answers => {
                        "capital center switzerland is:" => ["bern"],
                        "cats like:" => ["humans feed"],
                        "door:" => ["covered water"],
                        "meaning life?" => ["enjoy sunlight"],
                        "today date:" => ["throw away computer"],
                        },
pretty_question     => {
                        "capital center switzerland is:" => "The capital center of switzerland is:",
                        "cats like:" => "Cats like:",
                        "door:" => "The Door:",
                        "meaning life?" => "What is the meaning of life?",
                        "today date:" => "Today is the date:",
                        },
pretty_answer       => {
                        "basel"                  => "Basel",
                        "berlin"                 => "Berlin",
                        "bern"                   => "Bern",
                        "biel"                   => "Biel",
                        "closed"                 => "Is closed",
                        "covered blood"          => "Is covered with blood",
                        "covered water"          => "Is covered with water",
                        "cry day"                => "To cry all day",
                        "delete computer"        => "To delete my computer",
                        "dogs calm"              => "dogs who are calm",
                        "eat cat food"           => "To eat cat food",
                        "eat sandwich"           => "To eat a sandwich",
                        "enjoy sunlight"         => "To enjoy the sunlight",
                        "humans feed"            => "humans who feed them",
                        "jump water"             => "To jump into the water",
                        "locked"                 => "Is locked",
                        "open"                   => "Is open",
                        "put glasses"            => "To put the glasses on",
                        "study computer science" => "To study computer science",
                        "throw away computer"    => "To throw away my computer",
                        "treated kindly"         => "To be treated kindly",
                        "walk great miles"       => "To walk great miles",
                        "walk outdoor woods"     => "To walk outdoor in the woods",
                        "work till die"          => "To work till you die",
                        "zuerich"                => "Zuerich",
                        },
printed_question    => {
                        "capital center switzerland is:" => "2. The capital center of switzerland is:\n",
                        "cats like:" => "4. Cats like:\n",
                        "door:" => "1. The Door:\n",
                        "meaning life?" => "5. What is the meaning of life?\n",
                        "today date:" => "3. Today is the date:\n",
                        },
printed_answer      => {
                        "basel"                  => "    [ ] Basel\n",
                        "berlin"                 => "    [ ] Berlin\n",
                        "bern"                   => "    [ ] Bern\n",
                        "biel"                   => "    [ ] Biel\n",
                        "closed"                 => "    [ ] Is closed\n",
                        "covered blood"          => "    [ ] Is covered with blood\n",
                        "covered water"          => "    [ ] Is covered with water\n",
                        "cry day"                => "    [ ] To cry all day        \n",
                        "delete computer"        => "    [ ] To delete my computer\n",
                        "dogs calm"              => "    [ ] dogs who are calm\n",
                        "eat cat food"           => "    [ ] To eat cat food\n",
                        "eat sandwich"           => "    [ ] To eat a sandwich\n",
                        "enjoy sunlight"         => "    [ ] To enjoy the sunlight\n",
                        "humans feed"            => "    [ ] humans who feed them \n",
                        "jump water"             => "    [ ] To jump into the water\n",
                        "locked"                 => "    [ ] Is locked\n",
                        "open"                   => "    [ ] Is open\n",
                        "put glasses"            => "    [ ] To put the glasses on \n",
                        "study computer science" => "    [ ] To study computer science\n",
                        "throw away computer"    => "    [ ] To throw away my computer\n",
                        "treated kindly"         => "    [ ] To be treated kindly\n",
                        "walk great miles"       => "    [ ] To walk great miles\n",
                        "walk outdoor woods"     => "    [ ] To walk outdoor in the woods\n",
                        "work till die"          => "    [ ] To work till you die\n",
                        "zuerich"                => "    [ ] Zuerich\n",
                        }
```

## 2. Fuzzy Matching 
To evaluate the completed multiple-choice exams, the marked answers must be compared with the correct answers from the master file. There were instances where some of the completed multiple-choice exams deviated from the original template, for example, when some words in a question were written differently.

To help `Exam_Scorer` recognize such deviations from the original, the questions and answers were simplified. First, the strings were normalized using the following steps:

1. Removes brackets (answers) or numbers (questions).
2. Removes leading and trailing spaces.
3. Removes line breaks.
4. Replaces multiple spaces between words with a single space.
5. Converts all characters to lowercase.
6. Removes stop words.

For example:
```
"    [ ] To throw away my computer\n" becomes "throw away computer" in the normalized form.
```

To allow similar questions or answers to be accepted, the original and the deviation were compared using the Levenshtein distance. The Levenshtein distance measures how many single-character edits—insertions, deletions, or substitutions are required to transform one string into another.

The deviation was accepted if the edit distance was less than or equal to 10% of the length of the original string.

For example:
```
"today date#" is accepted as "today date:"
```

However, this type of matching also has disadvantages. For instance, a slightly different answer could be accepted even if it is actually incorrect and happens to match another incorrect answer option.
 
## 3. Collusion Detection 
The collusion detection mechanism compares the incorrect answers of a student with those of their peers to estimate the likelihood of cheating. The algorithm begins by identifying how many questions a student answered incorrectly and then checks whether any of these incorrect answers match with those of other students.

The probability of cheating is determined by the ratio of matching incorrect answers to the total number of incorrect answers. If this probability exceeds 50%, and the student has a sufficient number of wrong answers relative to the total questions, the student is flagged for potential cheating.

The formula for calculating the probability is:
```latex
P = \left( \frac{I}{W} \right) \times 100
```

\( I \) is the number of identical incorrect answers,  
\( W \) is the total number of incorrect answers given by the student,  
\( P \) is the calculated probability as a percentage.