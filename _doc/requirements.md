# ThinkSpace updates
Requirements and tweaks for the revisiting of the current production system.

# Core technology
The system is running the following versions:
  * Ember 1.11.1
  * Node  0.12.18
  * Rails 4.2.3
    * Ruby 2.5.5

Our repository can be found at:
  * https://github.com/sixthedge/thinkspace/
    * `master` branch is stable, `development` will be in flux as coding happens.

# Application update priorities

## Phase 1
Development to be finished in early August 2019, targeting the fall semester at ISU.  The Bookstore notes that we will know how many faculty and students are using the system by the first week in August.

### Security
#### High
  * Require a stronger password policy.
    * Only for accounts moving forward, will not require a change of password from everyone.
    * Based on NIST guidelines (SP 800-63B-3) the passwords will:
      * Be a minimum of at least 8 characters in length.
      * Allow up to at least 64 characters in length.
      * Allows all printing ASCII characters as well as the space character.
        * We may not even need to change what we have, based on this.  As long as it supports the rest of them.
      * Rate limit the number of failed authentication attempts.
      * Additional details from the NIST guideline that we may consider:
        * The verifier (ThinkSpace) shall _not_ impose any composition rules.
        * The verifier shall _not_ require passwords to be charged arbitrarily.
        * The verifier shall _not_ allow the user to store a hint.
        * The verifier will check passwords against commonly-used, expected, or compromised values.  Examples include dictionary words, repetitive or sequential characters ('aaaaaaaa', '1234abcd').
        * The verifier _should_ provide a password strength meter to assist choosing a strong password.
  * Rate limit login attempts for a given account.
    * Allow for 50 (make this configurable) failed authentication attempts in a given day **from a given IP address**.
      * If we based it on the email alone, it opens a DDOS possibility against the account from a malicious user.
    * If the limit is exceeded, enforce a 30 minute (make this configurable) window before authentication can occur.
      * This should come with a message saying to contact support if this is in error from the account specified.
  * Make sure that the legal notices are linked correctly on sign up, sign in, and any other existing links.
    * Terms of Service: https://s3.amazonaws.com/thinkspace-prod/legal/terms.pdf
    * Privacy Notice: https://s3.amazonaws.com/thinkspace-prod/legal/privacy-policy.pdf
      * Note the name change from Privacy Policy to Privacy Notice.  File name on S3 cannot change due to static links in ISU's systems.

---

### Bug fixes
#### High
  * Figure out how it's possible that a `PhaseScore` can be created twice.
    * Start with a database unique constraint on phase_state and see how it works.
    * A major problem with generating reports is that it gets hung up on the validation to check against the number of `PhaseScore` records.  Somehow, there can be more than one generated for the ownerable/phase pairing and it catches in the `assignment_score.rb` file at https://github.com/sixthedge/thinkspace-api/commit/413514bd044d72f7a5b32d4d1880dcc1f9dc5c1b.  The change made in that commit was after evaluating most of the cases and it was very commonly a score of 0 and the actual score, higher than 0.  Validations in the phase model look correct and I've long suspected this has to do with manual scoring in the gradebook.
  * Allow for cloning of _all_ spaces.
    * Currently, cloning is disabled for cases that have peer evaluations.  I don't remember why this was a limitation, but we need to either resolve the issue or ignore peer evaluations during the clone process.  It would be ideal to be able to clone them.  For a bit of information, I have manually cloned these via the terminal for instructors before and do not recall any negative side effects.
  * Make the gadebook/peer review student selector bar sticky.
    * Students often submit tickets wondering where peer review is because they have scrolled down.
    * If this is a large project, it could be ignored.


---

### Quality-of-life
#### High
  * Option to disable the success notifications (e.g. "Horray, Observation saved!") for the rest of their session.
    * This is a **very** common request from students working in the diagnostic path.
    * The intent is to do this client-side and not have a server-backed user settings or anything like that.  It would be a global `totem-messages` setting to toggle the flag to not show them.
  * Allow for a CSV upload to create teams.
    * This would allow the instructor to upload a CSV formatted like below:
      * | email   | first_name | last_name | team |
        | ------- | ---------- | --------- | ---- |
        | j@j.com | Jim        | Smith     | Red  |
        | y@y.com | Sally      | Samson    | Blue |
      * When uploaded, the parser will need to check for the corresponding header row to determine the column data.  Ideally, it could verify that the `email` column has a valid email value (first or random in the column).
      * When uploaded, the system will need to check for an existing `team_set` tied to the `space`.  If it exists, it will TODO: [modify it, or create a new one].
      * If an `email` does not already have an account, it should create the user, add them to the space roster, then invite them.  Effectively, it's as if they were added to the roster page and assigned to a team.

#### Medium
  * Once supported via the team CSV upload, extend the addition of allowing for `first_name` and `last_name` to the roster upload itself.

#### Low
  * Add the `iframe` tool to CKEditor, if it exists.
    * If CKEditor has an option we can enable to allow for `iframe` tags to be added, we should enable it.  If it does not, we will not be building the plugin as of now.

---

### Diagnostic path
#### High
 * Fix the diagnostic path from double rendering when in gradebook mode.
    * When an instructor access the gradebook and selects a student, the student's path stacks below the instructor's path.  Then, selecting a new student continues to stack them.  This is really confusing and makes it difficult to review paths without refreshing inbetween.


---
    
### Cost reduction
#### High
  * Paginate the `spaces#index` page _or_ implement a way to prevent a super user from loading the entire payload.
    * As of now, this is the major bottle neck from scaling down the servers on the Heroku side.  It requires a fairly beefy machine to not run into the 30 second timeout on the Heroku side.
    * With this, we accept that finding spaces will become significantly more difficult from a support perspective and we will rely on Crisp to provide the information.
    * If we go down the pagination route, the ability to dump the current set of spaces into CSV format for lookup via a terminal (`heroku console`) should be present.  This would likely just be a rake task that outputs the CSV string to the terminal.  Other options (e.g. downloadable report) could be considered.
      *  | id | title | instructor_emails | instructor_last_names | number_of_users |
         | -- | ----- | ----------------- | --------------------- | --------------- |
         | 1  | Dev.  | j@j.com,y@y.com   | Smith, Samson         | 150             | 

---

### Code cleanup
#### High
  * Remove all Discourse related functions, e.g. syncing to talk.thinkspace.org as this is no longer used.
    * This _may_ already be removed, I am not sure at the moment.

#### Medium
  * Consider removal of the `team collaboration` phase type.
    * It is extremely brittle with the dilemma of last write wins.  If we do port to Rails 5, perhaps we could reimplement with an ActionCable-backed method to allow for this to function more appropriately.  It would need to be very simple (e.g. only X team member can write, but others can watch).  If we do get to this point, we would have iRAT/tRAT, peer evaluation, and application exercises to round out the TBL suite.
    
---

### Peer evaluation
#### High
  * Figure out an alternative method to activating the peer evaluation outside of burying it in the settings.
    * The setting should likely remain buried in the "Settings" in the builder, but an additional method should be added.
    * A huge number of tickets reflect that faculty are confused with the _case_ being active (e.g. in the confirmation page of the builder, or the `cases#show` screen).  Perhaps the activation or status of the evaluation itself could be shown here as well or activated in conjunction with the case itself.
  * Peer evaluation results phase should unlock for everyone, not just those with sent reviews.
    * Per Holly/Kajal: The peer evaluations locked phase needs to open for EVERYBODY – not just for those who were approved and participated and even those who did not participate in the peer evaluation should be able to view the feedback they received – that is important in itself for TBL. 

#### Medium
  * Look at adding in Holly's requested feature for the balance points peer evaluation.  Effectively, it's a toggle that removes the requirement for all students to have differing points.
    * As of now, it's hard coded that all of the students cannot be allocated the same results.  For example, on a team of four, you will be evaluating three other peers and have 30 points to balance across the three students.  The current implementation prevents you from allocating 10, 10, 10 as the scores.  Holly's setting would allow this.
  * Fix the notification process for peer evaluations to not require them to be "in progress" for the state.
    * You cannot message students who have not yet started their evaluations, only those who are "in progress".
    * This will require a change to how it works currently, as it's basing it on the review set.  It will need to take in an email or user ID to use, as a student who has not yet started their evaluation will not have a review set.

#### Low
  * When editing a peer evaluation from the builder side, moving a duplicated scale up/down does not reorder the numbering.
    * The solution here is to likely render it with a relative index instead of storing it as it does now.
  * Add ability for an instructor to notify all non-submitted peer evaluation students a reminder.
    * JF: Currently have questions out if this should be custom text or a standard template.

---

### Builder
#### High
  * Always show the toolbar options inside of the _phase editor_ instead of displaying them only when hovering.
    * To edit a tool currently, you have to hover over the tool then select "Content" in the menu that appears.  This menu should always be visible, as the UX of the hovering process is poor.

---

## Phase 2
Development to occur if the system proves to be financially viable based on the seat charge revenue, a strongly promising business opportunity, or outside funding is acquired.
 
**Note that this section is uncategorized for now outside of general priority strengths.**

### High
  * LTI 1.1 integration so ThinkSpace can be embedded within Canvas.
    * I believe that this could be ported in from https://github.com/sixthedge/cellar/tree/development/src/thinkspace/api/thinkspace-ltiv1, although the compatibility is unknown with Rails 4.  It's known to support Ruby 2.3.1 with Rails 5.0.1.
    * Docker container for Canvas can be found at https://hub.docker.com/r/instructure/canvas-lms which can be used for development purposes.
      * This will require you to setup a few things within Canvas, although it's fairly simple to get going.  James can walk through any setup of Canvas if needed.
    * Need to remember/figure out how this has impacts with existing accounts.  LTI will allow the student to sign in automatically via their ISU-backed login.  This needs to sync with any already existing ThinkSpace accounts.
      * Any accounts coming from LTI are a source of truth.  Since the ThinkSpace accounts can be made with any email, it's possible that a malicious user could've already registered a student's email address as a hand-made ThinkSpace account.  To prevent this, we may need to reset their password automatically or some other means of disabling the hand-created acount and require them to reactivate it somehow via email authentication (e.g. if they have access to the email address to reset their password, they're good to go).
    * Simple solution is to require email validation on an account creation.
  * Revamp the marketing web page into something more appropriate with the messaging, tone, and voice.
  * Actually flesh out the template selections portion of the builder.
    * Perhaps categorize by pedagogy or some other method.  Currently, it's effectively a complete joke and provides no real value.
    * JF: Reach out to Kajal to determine potential case templates to have here for highest impact.

---

### Medium
  * Allow for the students to submit a phase past the due date of a case.
    * This will mitigate one of the largest categories of support tickets we see - "how do I extend the deadline for X student?" 
  * Make the status of a peer evaluation more obvious to the student.
    * We get a lot of tickets regarding how it shows that the case is not complete due to the results phase not being submitted.
    * Is it possible to have a different `cases#show` for strict peer evaluation cases?
  * Add the ability within CKEditor to more easily implement a carry forward tag.
    * This has to be done via the source code at the moment and is prohibitive to instructors.
    * The idea is that there would be a toolbar option which would open a list (modal?) of possible values from previous phases which could then be selected.  The list of targets ideally would include the multiple choice questions or checkbox wrappers as noted below (medium for MCQ, low for checkbox).
  * Add the ability within CKEditor to create multiple choice questions (MCQ) with carry forward possibilties.
    * Currently, adding a radio button is borderline impossible for someone without understanding of HTML.  The implementation here would be a simple MCQ form _without_ any scoring or correctness designations.  It would allow for them to create basic MCQs and then select the group as a carry forward target.
  * Add the ability within CKEditor to create a set of checkboxes more easily.
    * Currently, they can add a single checkbox, although it is clumsy.  The end goal would be to have some sort of wrapper to signify that a set of checkboxes are related content.  For example, something like "Select all of the pizza toppings you would like" is a representative prompt for something they would add.  Then, the wrapper could be carry forwarded, much like MCQs.
  * Allow for image (or file?) uploading on behalf of the instructor to then use in a case.
    * Many, many tickets have came in from instructors trying to figure out how to add an image to a case.  Currently, there is not a great method of doing so.
    * This would be dead simple, e.g. select a file -> uploaded -> here is the URL.  No image browser, library, etc.
  * Allow for the ability for an instructor to clear the data for a student's entire case.
    * Currently, we only have it for the phase specifically and they have to do it one by one.  This is really tedious for the larger cases.
    * This is mainly going to be used by faculty who use it to test the system.
    * There needs to be an approval process (e.g. type in your email to confirm) as this could be very dangerous.
  * If the user is using Safari, it would be nice to display a banner to warn them that the system functions best with Firefox or Chrome.
    * Safari generally works, but frequently chokes on the PDF rendering for the bucket.
    * Ideally this could be generalized to allow to target multiple browser types/versions, if possible.  That would allow us to use features such as CSS Grid an notify IE11 as well.
  * Produce support materials for the following common support topics:
    * How to clear the phase data for an ownerable.
    * How to use the gradebook to view the work of an ownerable.
    * How to manually set the score for a ownerable's work.
  * Simplify the approval process for peer evaluations from the instructor's dashboard.
    * Comment from Holly/Kajal: Simplifying approval process – too many options right now that are very unclear to faculty.
    * JF: I agree with the comment, but would need to collaborate on what that specifically means.  OpenTBL was a step in a better direction in my opinion.
  * Add a feature where an instructor can resend invitations and reminders to all students who have not yet signed up.
    * This would be a nice QOL upgrade, but need to determine the impacts between this and LTI.

---

### Low
  * Allow for manual entry of times _or_ the addition of 11:59 PM to the drop-down menu.
    * Many faculty have requested this, as it's very common to see an assignment due at 11:59 PM to avoid confusion.
  * Provide a builder for peer evaluation cases so they do not get bogged down in the more complex case builder.
    * Effectively, this would be looking at porting something like what OpenTBL had.  It's a different, more streamlined version of the builder to allow for simplified creation of peer evaluations.  This will be a major component for keeping our peer evaluation tools competitive and desirable.
  * Add in a way to download the report for the Dynamic Weather Forecaster.
    * This is something only used by one faculty as of now (and perhaps they will not after the seat charge change), but it's something I have to manually produce.  It's simplified down to `rake thinkspace:weather_forecaster:score:dump`, but would be nice to have it in-app as a self serve function _if_ the instructor continues to use the system.
      * JF: I will follow up with the instructor to see if they will continue to use the system.
  * If the `spaces#index` page has been paginated, it would help to have a search function for super users to more easily find the correct space for support.  Currently, we get a lot of this data via Crisp (the Intercom replacement, support system), so it's likely not that big of an issue.  If we ever switch to basic email instead of in-app for support, this requirement becomes notably higher priority.
  * Show metadata about previous/next phases in the builder.
    * It is confusing when editing to understand "where" you are in the case when in the phase editor.  Simple information, such as next/previous phase titles would help.
    * JF: Would need to work with Kajal to determine what this specifically would mean.  As of now, it's more of the technical requirement of accessing the next/previous phase information from the Ember side.
  * Add the ability to upload more than one file per phase with the Artifact Bucket tool.
    * This, if I recall correctly, would break the PDF markup capabilities.
    * Probably a sub project of a PDF file upload UI revamp.

---

#### Validation needed
Features noted by a stakeholder that need verified through paying instructors.

  * Allow for the two submit options: lock the phase as it does now or to allow multiple submissions.
    * We had this in the Elixir version, but the way we were storing the data made the system well suited for this.  I am imagining that this is a large project and not something to look at for awhile/at all.
  * Add "instructions" for a diagnostic path.
    * This would be an instructor-defined field that would display above the path itself.
  * Implement a way for a student to score themselves in the peer evaluation process, ignoring it for calcuations.
    * This was recommended by Holly/Kajal, but I have marked as low as it will likely be a large project.

---

## Phase 3
This is the "pie in the sky" or "if we had a billion dollars" section.  There are no severity categories for this section.
  * It is worth considering writing end-to-end tests for the most common case types, determined by the seat charges.
  * In a perfect world where we all have millions of dollars, we would have JSON API format instead of the current serilization format.
  * In a perfect world where we all have millions of dollars, we would update to a more recent Ember (or port to Vue, React, etc) version.
    * Including an update to Yarn.