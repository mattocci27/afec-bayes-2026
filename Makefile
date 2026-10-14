# Render the 2026 AFEC instructor materials from the project root.
PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
QUARTO ?= quarto

.PHONY: help day1 day2 day3 slides

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make day1   Render Day 1 slides and instructor exercise' \
	  '  make day2   Render Day 2 slides and instructor exercise' \
	  '  make day3   Render Day 3 slides and instructor exercise' \
	  '  make slides Render all three slide decks' \
	  '  make help   Show this help'

day1:
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/exercise.qmd

day2:
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/exercise.qmd

day3:
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/exercise.qmd

slides:
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/slides.qmd
