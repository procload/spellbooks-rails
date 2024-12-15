class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('MAILER_FROM_EMAIL', 'noreply@spellbooks.ai')
  layout "mailer"

  def assignment_ready_email
    @teacher = params[:teacher]
    @assignment = params[:assignment]

    mail(
      to: @teacher.email_address,
      subject: "Your Assignment '#{@assignment.title}' is Ready!"
    )
  end

  def assignment_failed_email
    @teacher = params[:teacher]
    @assignment = params[:assignment]
    @error = params[:error]

    mail(
      to: @teacher.email_address,
      subject: "Assignment '#{@assignment.title}' Generation Failed"
    )
  end
end
