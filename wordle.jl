module Wordle

using DelimitedFiles
using Random

const word_database = readdlm("5LetterWords.txt", '\n', String)

function choose_word()
    return rand(word_database)
end

function evaluate_guess(guess, target_word)
    guess = lowercase(guess)
    correct_letter = []
    correct_location = []
    incorrect = []
    for (guess_indx, guess_char) in enumerate(guess)
        if !(guess_char in target_word)
            push!(incorrect, guess_char)
        elseif target_word[guess_indx] == guess_char
            push!(correct_location, [guess_char,guess_indx])
        else
            if count(i->i==guess_char, target_word) > count(i->i==guess_char, vcat(correct_letter,correct_location))
                if guess_indx == 5
                    push!(correct_letter, [guess_char,guess_indx])
                elseif count(i->i==guess_char, target_word) > count(i->i==guess_char, guess[guess_indx+1:5])
                    push!(correct_letter, [guess_char,guess_indx])
                end
            end
        end
    end
    return correct_letter, correct_location, incorrect
end

function remove_letters!(letters, correct_letter, correct_location, incorrect)
    for char in correct_letter
        deleteat!(letters, letters .== char[1]);
    end
    for char in correct_location
        deleteat!(letters, letters .== char[1]);
    end
    for char in incorrect
        deleteat!(letters, letters .== char[1]);
    end
    return letters
end


function play()
    target_word = choose_word()
    round = 1
    letters = [char for char in 'A':'Z']
    while round < 7
        println("\nRound $round")
        println("\nUnguessed Letters: ", letters...)
        println("\nGuess a 5 letter word:")
        guess = readline()
        if length(guess) != 5 || !all(isletter, guess)
            println("Guess must be a 5 letter word with no special charaters or spaces")
        elseif !(guess in word_database)
            println("Word not in database, guess again")
        elseif lowercase(guess) == lowercase(target_word)
            println("Congratulations, you win!")
            return true
        else
            correct_letter, correct_location, incorrect = evaluate_guess(guess, target_word)
            println("\nCorrect Letters (Wrong Location): ", sort(uppercase.([pair[1] for pair in correct_letter]))...)
            println("Correct Letters (Right Location): ", sort(uppercase.([pair[1] for pair in correct_location]))...)
            println("Incorrect Letters: ", sort(uppercase.(incorrect))...)
            remove_letters!(letters, correct_letter, correct_location, incorrect)
            round += 1
        end
    end
    println("Ran out of guesses, you lose.")
    println("Correct word was $target_word")
    return false
end


end #module
