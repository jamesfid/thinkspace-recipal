module Thinkspace
  module PeerAssessment

    class AssessmentMailer < ActionMailer::Base
      default from: 'ThinkBot <thinkbot@thinkspace.org>'

      def notify_overview_unlocked(assessment, user)
        @user            = user
        @to              = user.email
        @phase           = assessment.overview_phase
        @assignment      = @phase.thinkspace_casespace_assignment

        raise "Cannot send a notification without an email [#{@to}]." unless @to.present?
        raise "Cannot send a notification without a phase [#{@phase}]." unless @phase.present?
        raise "Cannot send a notification without an assignment [#{@assignment}]." unless @assignment.present?

        # TODO: Figure out a better way to determine host, maybe from config?
        url_suffix = "casespace/cases/#{@assignment.id}/phases/#{@phase.id}?query_id=none"
        @url       = 'http://localhost:4200/' + url_suffix if Rails.env.development?
        @url       = 'https://think.thinkspace.org/' + url_suffix if Rails.env.production?
        subject    = "[ThinkSpace] Peer Evaluation Unlocked for #{@assignment.title}"

        mail(to: @to, subject: subject)
      end

      def notify_ownerable(assessment, ownerable, message)
        @message   = message
        @ownerable = ownerable
        @url       = get_assessment_url(assessment)
        @to        = @ownerable.email
        raise "Cannot send a notification without an email [#{@to}]." unless @to.present?
        subject = "[ThinkSpace] Instructor Notification - Peer Evaluation"
        mail(to: @to, subject: subject)
      end

      def notify_incomplete(assessment, ownerable)
        @ownerable = ownerable
        @url       = get_assessment_url(assessment)
        @to        = @ownerable.email
        raise "Cannot send a notification without an email [#{@to}]." unless @to.present?
        subject = "[ThinkSpace] Instructor Notification - Peer Evaluation - Reminder"
        mail(to: @to, subject: subject)
      end

      private

      def get_assessment_url(assessment)
        raise "Cannot get URL without an assessment." unless assessment.present?
        phase = assessment.authable
        raise "Cannot get URL without a phase [#{phase}]" unless phase.present?
        assignment = phase.thinkspace_casespace_assignment
        raise "Cannot get URL without an assignment [#{assignment}]" unless assignment.present?
        url_suffix = "casespace/cases/#{assignment.id}/phases/#{phase.id}?query_id=none"
        url        = 'http://localhost:4200/' + url_suffix if Rails.env.development?
        url        = 'https://think.thinkspace.org/' + url_suffix if Rails.env.production?
        url
      end

    end

  end
end
