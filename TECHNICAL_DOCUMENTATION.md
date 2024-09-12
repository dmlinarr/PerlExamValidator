# Technical Documentation

## 1. Data structure 
Text...



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

## 2. Fuzzy matching 
why? example.

## 3. Colusion detection 
why? example.