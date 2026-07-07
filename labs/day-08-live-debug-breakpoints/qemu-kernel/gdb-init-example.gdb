set pagination off
target remote :1234

# Replace suspect_function with the boundary chosen in the Day 8 note.
hbreak suspect_function
continue

