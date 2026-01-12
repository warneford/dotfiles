# Test file for R LSP
# After restarting Claude Code, the LSP should catch issues here

library(dplyr)

# This should show hover info for functions
my_function <- function(x, y) {
  result <- x + y
  return(result)
}

# Intentional typo - undefined variable
test_value <- undefined_variable + 10
another_error <- also_undefined * 2

# Call the function
output <- my_function(5, 3)
print(output)
