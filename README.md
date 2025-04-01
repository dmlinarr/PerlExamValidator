# Perl Exam Validator Tool

This project provides a suite of Perl scripts for managing multiple-choice exams, including randomization, scoring, and basic collusion detection.

## Applications

The following applications are included:

* **`Exam_Randomizer.pl`**: Reads a master multiple-choice exam file and generates a randomized version of the exam.
    
    **Usage:**
    ```bash
    perldoc src/Exam_Randomizer.pl
    ```
    

* **`Exam_Scorer.pl`**: Evaluates completed multiple-choice exams against a master exam file, providing scores, identifying incorrect answers, and detecting potential cheating.
    
    **Usage:**
    ```bash
    perldoc src/Exam_Scorer.pl
    ```