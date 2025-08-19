#!/bin/bash

N=20
M=40
SNAKE_HEAD='@'
SNAKE_BODY='O'
FOOD='*'
EMPTY=' '
BORDER='#'
declare -A grid
declare -a snake_x
declare -a snake_y
snake_length=5
snake_dir='d'
score=0
food_x=0
food_y=0
game_over=false

initialize_game() {
    # Initialize the grid
    for (( i=0; i<N; i++ )); do
        for (( j=0; j<M; j++ )); do
            grid[$i,$j]=$EMPTY
        done
    done

    # Initialize the snake
    head_x=10
    head_y=20
    for (( i=0; i<snake_length; i++ )); do
        snake_x[$i]=$head_x
        snake_y[$i]=$((head_y-i))
        grid[$head_x,$((head_y-i))]=$SNAKE_BODY
    done
    grid[$head_x,$head_y]=$SNAKE_HEAD

    place_food
}

place_food() {
    food_x=$((RANDOM % N))
    food_y=$((RANDOM % M))
    while [ "${grid[$food_x,$food_y]}" != "$EMPTY" ]; do
        food_x=$((RANDOM % N))
        food_y=$((RANDOM % M))
    done
    grid[$food_x,$food_y]=$FOOD
}

print_grid() {
    clear
    # Print top border
    for (( j=0; j<=M+1; j++ )); do
        echo -n "$BORDER"
    done
    echo

    # Print grid with side borders
    for (( i=0; i<N; i++ )); do
        echo -n "$BORDER"
        for (( j=0; j<M; j++ )); do
            echo -n "${grid[$i,$j]}"
        done
        echo "$BORDER"
    done

    # Print bottom border
    for (( j=0; j<=M+1; j++ )); do
        echo -n "$BORDER"
    done
    echo

    echo "Score: $score"
}

move_snake() {
    local new_x=${snake_x[0]}
    local new_y=${snake_y[0]}

    case $snake_dir in
        d) ((new_y++)) ;;
        a) ((new_y--)) ;;
        w) ((new_x--)) ;;
        s) ((new_x++)) ;;
        D) ((new_y++)) ;;
        A) ((new_y--)) ;;
        W) ((new_x--)) ;;
        S) ((new_x++)) ;;
    esac

     # Wrap around
    ((new_x=(new_x+N)%N))
    ((new_y=(new_y+M)%M))

    if [ "${grid[$new_x,$new_y]}" == "$SNAKE_BODY" ]; then
        game_over=true
        return
    fi

    if [ "${grid[$new_x,$new_y]}" == "$FOOD" ]; then
        ((score+=10))
        ((snake_length++))
        place_food
    else
        # Remove the tail
        local tail_index=$((snake_length-1))
        local tail_x=${snake_x[$tail_index]}
        local tail_y=${snake_y[$tail_index]}
        grid[$tail_x,$tail_y]=$EMPTY
        snake_x=("${snake_x[@]:0:$tail_index}")
        snake_y=("${snake_y[@]:0:$tail_index}")
    fi

    # Move snake's head
    grid[${snake_x[0]},${snake_y[0]}]=$SNAKE_BODY
    grid[$new_x,$new_y]=$SNAKE_HEAD
    snake_x=($new_x "${snake_x[@]}")
    snake_y=($new_y "${snake_y[@]}")
}

read_input() {
    read -n 1 -t 0.1 key
    case $key in
        d|a|w|s|D|A|W|S) snake_dir=$key ;;
    esac
}

# game-end
handle_game_over() {
    while true; do
        echo "Game Over LOSER! Final Score: $score"
        echo "Press 'Enter' to play again or 'Esc' to exit."
        read -rsn1 input
        if [[ $input == "" ]]; then
            game_over=false
            score=0
            snake_length=5
            snake_dir='d'
            initialize_game
            break
        elif [[ $input == $'\e' ]]; then
            exit 0
        fi
    done
}

initialize_game
while true; do
    while ! $game_over; do
        read_input
        move_snake
        print_grid
        sleep 0.3
    done
    handle_game_over
done

echo "Game Over! Final Score: $score
