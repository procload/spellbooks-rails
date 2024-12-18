import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "subject", "gradeLevel", "difficulty", "questions", "interests"]

  fillRandom() {
    // Random title
    const subjects = ['Math', 'Science', 'History', 'English', 'Art']
    const topics = [
      'Fundamentals', 'Advanced Concepts', 'Introduction to', 'Deep Dive into',
      'Exploring', 'Understanding', 'Mastering', 'Discovering', 'Journey through'
    ]
    const subtopics = {
      Math: ['Algebra', 'Geometry', 'Calculus', 'Statistics', 'Probability', 'Number Theory', 'Trigonometry'],
      Science: ['Biology', 'Chemistry', 'Physics', 'Astronomy', 'Earth Science', 'Environmental Science'],
      History: ['Ancient Civilizations', 'World Wars', 'Renaissance', 'Industrial Revolution', 'Civil Rights'],
      English: ['Literature', 'Poetry', 'Grammar', 'Creative Writing', 'Shakespeare', 'American Authors'],
      Art: ['Painting', 'Sculpture', 'Photography', 'Digital Art', 'Art History', 'Modern Art']
    }

    // Pick random subject
    const subject = subjects[Math.floor(Math.random() * subjects.length)]
    const topic = topics[Math.floor(Math.random() * topics.length)]
    const subtopic = subtopics[subject][Math.floor(Math.random() * subtopics[subject].length)]
    
    // Set title
    this.titleTarget.value = `${topic} ${subtopic}`

    // Set subject
    const subjectInput = document.querySelector(`input[name="assignment[subject]"][value="${subject}"]`)
    if (subjectInput) subjectInput.click()

    // Random grade level (K-12)
    const gradeLevel = Math.floor(Math.random() * 13).toString()
    this.gradeLevelTarget.value = gradeLevel

    // Random difficulty
    const difficulties = ['Easy', 'Medium', 'Hard', 'Advanced']
    const difficulty = difficulties[Math.floor(Math.random() * difficulties.length)]
    const difficultyInput = document.querySelector(`input[name="assignment[difficulty]"][value="${difficulty}"]`)
    if (difficultyInput) difficultyInput.click()

    // Random number of questions (3-10)
    this.questionsTarget.value = Math.floor(Math.random() * 8) + 3

    // Random interests based on subject
    const interestsBySubject = {
      Math: ['Problem Solving', 'Logic Games', 'Puzzles', 'Real-world Applications', 'Technology'],
      Science: ['Experiments', 'Nature', 'Technology', 'Space', 'Environment', 'Animals'],
      History: ['Ancient Cultures', 'Wars', 'Leaders', 'Inventions', 'Social Movements'],
      English: ['Stories', 'Poetry', 'Creative Writing', 'Drama', 'Public Speaking'],
      Art: ['Drawing', 'Painting', 'Digital Creation', 'Animation', 'Design']
    }

    // Pick 2-4 random interests
    const subjectInterests = interestsBySubject[subject]
    const numInterests = Math.floor(Math.random() * 3) + 2
    const selectedInterests = []
    
    while (selectedInterests.length < numInterests) {
      const interest = subjectInterests[Math.floor(Math.random() * subjectInterests.length)]
      if (!selectedInterests.includes(interest)) {
        selectedInterests.push(interest)
      }
    }

    // Set interests
    this.interestsTarget.value = selectedInterests.join(', ')
    // Trigger interests controller update
    const event = new Event('change', { bubbles: true })
    this.interestsTarget.dispatchEvent(event)
  }
}
