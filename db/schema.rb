# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_05_212838) do
  create_table "answers", force: :cascade do |t|
    t.string "text"
    t.boolean "is_correct"
    t.integer "question_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.string "title"
    t.string "subject"
    t.integer "grade_level"
    t.string "difficulty"
    t.integer "number_of_questions"
    t.text "interests"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "passage"
    t.string "status"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "assignment_id", null: false
    t.text "content"
    t.string "correct_answer"
    t.text "explanation"
    t.text "options"
    t.text "passage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_questions_on_assignment_id"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "questions", "assignments"
end
