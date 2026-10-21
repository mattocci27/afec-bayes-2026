# Build the 2026 AFEC materials from the project root.
PROJECT_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
QUARTO ?= quarto
RSCRIPT ?= Rscript
PYTHON ?= python3

.PHONY: help day1 day1-zip day2 day3 slides materials site publish

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make day1   Build Day 1 slides, exercises and result sheet' \
	  '  make day1-zip Build Day 1 materials and the Day 1-only participant ZIP' \
	  '  make day2   Build Day 2 slides, exercises and result sheet' \
	  '  make day3   Build Day 3 slides, exercises and result sheet' \
	  '  make slides Render all three slide decks' \
	  '  make materials Build all materials and the participant ZIP' \
	  '  make site   Build materials, ZIP and website in dist/site/' \
	  '  make publish Build the website and push it to origin/gh-pages' \
	  '  make help   Show this help'

day1: day1/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/exercise.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/results.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/instructor-notes.qmd

day1-zip: day1
	@cd "$(PROJECT_ROOT)" && $(PYTHON) scripts/build_day1_package.py

day2: day2/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/exercise.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/results.qmd

day3: day3/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/exercise.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/exercise-student.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/results.qmd

slides:
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day1/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day2/slides.qmd
	@cd "$(PROJECT_ROOT)" && $(QUARTO) render day3/slides.qmd

# Regenerate the solution-free source before rendering each day's handout.
day%/exercise-student.qmd: day%/exercise.qmd R/classroom_materials.R R/generate_student_sources.R
	@cd "$(PROJECT_ROOT)" && $(RSCRIPT) R/generate_student_sources.R day$*

materials:
	@cd "$(PROJECT_ROOT)" && $(RSCRIPT) R/build_classroom_materials.R

site: materials
	@cd "$(PROJECT_ROOT)" && $(PYTHON) scripts/publish_pages.py stage

publish: site
	@cd "$(PROJECT_ROOT)" && $(PYTHON) scripts/publish_pages.py publish
