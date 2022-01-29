module WordleKiller

using DelimitedFiles
using Random
using Main.Wordle

const letters = [char for char in 'a':'z']

const letter_to_num = Dict([letter => number for (letter, number) in zip('a':'z', 1:26)])

function filter_database!(database, correct_letters, correct_locations, incorrect)
    for incorrect_letter in incorrect
        indx_to_remove = []
        for (indx, word) in enumerate(database)
            if incorrect_letter in word
                push!(indx_to_remove, indx)
            end
        end
        deleteat!(database, indx_to_remove)
    end
    for correct_letter_pair in correct_locations
        indx_to_remove = []
        for (indx, word) in enumerate(database)
            if word[correct_letter_pair[2]] != correct_letter_pair[1]
                push!(indx_to_remove, indx)
            end
        end
        deleteat!(database, indx_to_remove)
    end
    for correct_letter_pair in correct_letters
        indx_to_remove = []
        for (indx, word) in enumerate(database)
            if word[correct_letter_pair[2]] == correct_letter_pair[1]
                push!(indx_to_remove, indx)
            end
        end
        deleteat!(database, indx_to_remove)
    end
end

function get_letter_probabilites(database)
    compressed_database = join(database)
    num_letters = length(compressed_database)
    letter_probs = zeros(26)
    for (i, letter) in enumerate(letters)
        letter_probs[i] = count(i->i==letter, compressed_database)/num_letters
    end
    return letter_probs
end

function individual_letter_prob_guess(database)
    letter_probs = get_letter_probabilites(database)
    max_prob = 0.0
    guess = ""
    for word in database
        prob = 1.0
        for letter in word
            prob *= letter_probs[letter_to_num[letter]]
        end
        if prob > max_prob
            max_prob = prob
            guess = word
        end
    end
    return guess
end

function random_word(database)
    return rand(database)
end

function play_one_game(verbose = true; database = vec(readdlm("5LetterWords.txt", '\n', String)), guess_alg = individual_letter_prob_guess)
    working_database = copy(database)
    target_word = random_word(working_database)
    round = 1
    guesses = []
    while round < 7
        guess = guess_alg(working_database)
        push!(guesses, guess)
        if guess == target_word
            if verbose
                println("Algorithm won! Target word was $target_word")
                println("\nThe guesses made were:\n")
                for (i, g) in enumerate(guesses)
                    println("Round $i: $g")
                end
            end
            return true, round
        end
        correct_letter, correct_location, incorrect = Wordle.evaluate_guess(guess, target_word)
        filter_database!(working_database, correct_letter, correct_location, incorrect)
        round += 1
    end
    if verbose
        println("Algorith lost! Target word was $target_word")
        println("\nThe guesses made were:\n")
        for (i, g) in enumerate(guesses)
            println("Round $i: $g")
        end
    end
    return false, round
end

end #module
