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
            if !(correct_letter_pair[1] in word) || word[correct_letter_pair[2]] == correct_letter_pair[1]
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

function play_one_game(verbose = true; database = vec(readdlm("5LetterWords.txt", '\n', String)), guess_alg = random_word)
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

function yesnoprompt()
    input = ""
    while input != "y" && input != "n"
        print("(y/n):")
        input = readline()
    end
    return input
end

function manual_prompts(database = vec(readdlm("5LetterWords.txt", '\n', String)), guess_alg = random_word)
    working_database = copy(database)
    round = 1
    while round < 7
        println("Round $round\n")
        guess = guess_alg(working_database)
        println("Guess is $guess\n")
        println("Is guess correct? ")
        input = yesnoprompt()
        if input == "y"
            println("Yay we won!")
            return true
        end
        incorrect = []
        correct_letters = []
        correct_locations = []
        keep_going = true
        while keep_going
            println("Which letters are incorrect?\n")
            input_letters = readline()
            if input_letters != ""
                incorrect = only.(split(input_letters,""))
            else
                incorrect = []
            end
            println("Incorrect letters are:", incorrect...)
            println("Is this right? ")
            input = yesnoprompt()
            if input == "y"
                keep_going = false
            end
        end
        keep_going = true
        while keep_going
            println("Which letters are correct, but in the wrong place?\n")
            input_letters = readline()
            if input_letters != ""
                lttrs = only.(split(input_letters,""))
            end
            println("What locations were they in, respectively?\n")
            input_nums = readline()
            if input_nums != ""
                locs = parse.(Int64, split(input_nums,""))
            end
            if input_letters != ""
                correct_letters = [[char, pos] for (char, pos) in zip(lttrs,locs)]
            else
                correct_letters = []
            end
            println("Correct letter, wrong location pairs are:", correct_letters...)
            println("Is this right? ")
            input = yesnoprompt()
            if input == "y"
                keep_going = false
            end
        end
        keep_going = true
        while keep_going
            println("Which letters are correct, and in the right place?\n")
            input_letters = readline()
            if input_letters != ""
                lttrs = only.(split(input_letters,""))
            end
            println("What locations were they in, respectively?\n")
            input_nums = readline()
            if input_nums != ""
                locs = parse.(Int64, split(input_nums,""))
            end
            if input_letters != ""
                correct_locations = [[char, pos] for (char, pos) in zip(lttrs,locs)]
            else
                correct_locations = []
            end
            println("Correct letter, right location pairs are:", correct_locations...)
            println("Is this right? ")
            input = yesnoprompt()
            if input == "y"
                keep_going = false
            end
        end
        filter_database!(working_database, correct_letters, correct_locations, incorrect)
        round += 1
    end
    println("We lost, oh well")
    return false
end

end #module
