Rails.application.routes.draw do
  get 'sudoku/home'
  get 'random/home'
  post 'random/random_sudoku'
  post 'sudoku/submit'
  root 'sudoku#home'
end
