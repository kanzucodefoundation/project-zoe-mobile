-- CreateTable
CREATE TABLE "person" (
    "person_id" TEXT NOT NULL,
    "firstname" TEXT NOT NULL,
    "lastname" TEXT NOT NULL,
    "phone" TEXT,
    "email" TEXT NOT NULL,
    "gender" TEXT,
    "civilStatus" TEXT,
    "birthday" TIMESTAMP(3),
    "address" TEXT,
    "place_of_work" TEXT,
    "age_group" TEXT,
    "country" TEXT,
    "district" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "person_pkey" PRIMARY KEY ("person_id")
);

-- CreateTable
CREATE TABLE "church" (
    "church_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,

    CONSTRAINT "church_pkey" PRIMARY KEY ("church_id")
);

-- CreateTable
CREATE TABLE "roles" (
    "role_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "permissions" TEXT[],
    "isActive" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("role_id")
);

-- CreateTable
CREATE TABLE "user" (
    "user_id" TEXT NOT NULL,
    "username" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "person_id" TEXT NOT NULL,
    "role_id" TEXT NOT NULL,
    "church_id" TEXT NOT NULL,

    CONSTRAINT "user_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "group" (
    "group_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "group_pkey" PRIMARY KEY ("group_id")
);

-- CreateTable
CREATE TABLE "group_membership" (
    "person_id" TEXT NOT NULL,
    "group_id" TEXT NOT NULL,
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "group_membership_pkey" PRIMARY KEY ("person_id","group_id")
);

-- CreateTable
CREATE TABLE "events" (
    "event_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "start_time" TIMESTAMP(3) NOT NULL,
    "end_time" TIMESTAMP(3) NOT NULL,
    "location" TEXT,

    CONSTRAINT "events_pkey" PRIMARY KEY ("event_id")
);

-- CreateTable
CREATE TABLE "event_attendance" (
    "person_id" TEXT NOT NULL,
    "event_id" TEXT NOT NULL,
    "registeredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "event_attendance_pkey" PRIMARY KEY ("person_id","event_id")
);

-- CreateTable
CREATE TABLE "report_type" (
    "report_type_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,

    CONSTRAINT "report_type_pkey" PRIMARY KEY ("report_type_id")
);

-- CreateTable
CREATE TABLE "report_attendance" (
    "person_id" TEXT NOT NULL,
    "report_submission_id" TEXT NOT NULL,

    CONSTRAINT "report_attendance_pkey" PRIMARY KEY ("person_id","report_submission_id")
);

-- CreateTable
CREATE TABLE "report_submission" (
    "report_submission_id" TEXT NOT NULL,
    "submission_date" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'Submitted',
    "submitter_user_id" TEXT NOT NULL,
    "report_type_id" TEXT NOT NULL,

    CONSTRAINT "report_submission_pkey" PRIMARY KEY ("report_submission_id")
);

-- CreateTable
CREATE TABLE "garage_report_data" (
    "report_submission_id" TEXT NOT NULL,
    "dateTimeOfGathering" TIMESTAMP(3) NOT NULL,
    "smallGroupName" TEXT NOT NULL,
    "smallGroupId" TEXT,
    "attendanceTotal" INTEGER NOT NULL,
    "attendanceTeens" INTEGER,
    "attendanceKids" INTEGER,
    "attendanceFTGs" INTEGER,
    "involvementVolunters" INTEGER,
    "contributionTithesOfferings" DECIMAL(10,2),
    "contributionProjects" DECIMAL(10,2),
    "contributionOther" DECIMAL(10,2),
    "involvementSmallgroupAttendance" INTEGER,
    "salvations" INTEGER,
    "inHouseSalvations" INTEGER,
    "salvationsBaptism" INTEGER,
    "salvationsRecommitments" INTEGER,
    "visitations" INTEGER,
    "dmcAttendance" INTEGER,
    "fireplaceAttendance" INTEGER,
    "careCallsMade" INTEGER,
    "frontiersEngaged" INTEGER NOT NULL,
    "numberOfMCs" INTEGER NOT NULL,
    "notes" TEXT
);

-- CreateTable
CREATE TABLE "mc_report_data" (
    "report_submission_id" TEXT NOT NULL,
    "date" TIMESTAMP(3) NOT NULL,
    "smallGroupName" TEXT NOT NULL,
    "smallGroupId" TEXT,
    "mcHostHome" TEXT NOT NULL,
    "smallGroupNumberOfMembers" INTEGER NOT NULL,
    "mcHuddleCount" INTEGER NOT NULL,
    "smallGroupAttendanceCount" INTEGER NOT NULL,
    "mcAttendeeNames" TEXT NOT NULL,
    "mcGeneralFeedback" TEXT NOT NULL,
    "mcWordHighlights" TEXT NOT NULL,
    "mcTestimonies" TEXT NOT NULL,
    "mcPrayerRequest" TEXT NOT NULL,
    "mcFrontierStory" TEXT
);

-- CreateIndex
CREATE UNIQUE INDEX "person_phone_key" ON "person"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "person_email_key" ON "person"("email");

-- CreateIndex
CREATE UNIQUE INDEX "church_name_key" ON "church"("name");

-- CreateIndex
CREATE UNIQUE INDEX "roles_name_key" ON "roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "user_username_key" ON "user"("username");

-- CreateIndex
CREATE UNIQUE INDEX "user_person_id_key" ON "user"("person_id");

-- CreateIndex
CREATE UNIQUE INDEX "report_type_name_key" ON "report_type"("name");

-- CreateIndex
CREATE UNIQUE INDEX "garage_report_data_report_submission_id_key" ON "garage_report_data"("report_submission_id");

-- CreateIndex
CREATE UNIQUE INDEX "mc_report_data_report_submission_id_key" ON "mc_report_data"("report_submission_id");

-- AddForeignKey
ALTER TABLE "user" ADD CONSTRAINT "user_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "person"("person_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user" ADD CONSTRAINT "user_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("role_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user" ADD CONSTRAINT "user_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "church"("church_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_membership" ADD CONSTRAINT "group_membership_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "person"("person_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "group_membership" ADD CONSTRAINT "group_membership_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "group"("group_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_attendance" ADD CONSTRAINT "event_attendance_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "person"("person_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_attendance" ADD CONSTRAINT "event_attendance_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("event_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_attendance" ADD CONSTRAINT "report_attendance_person_id_fkey" FOREIGN KEY ("person_id") REFERENCES "person"("person_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_attendance" ADD CONSTRAINT "report_attendance_report_submission_id_fkey" FOREIGN KEY ("report_submission_id") REFERENCES "report_submission"("report_submission_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_submission" ADD CONSTRAINT "report_submission_submitter_user_id_fkey" FOREIGN KEY ("submitter_user_id") REFERENCES "user"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "report_submission" ADD CONSTRAINT "report_submission_report_type_id_fkey" FOREIGN KEY ("report_type_id") REFERENCES "report_type"("report_type_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "garage_report_data" ADD CONSTRAINT "garage_report_data_report_submission_id_fkey" FOREIGN KEY ("report_submission_id") REFERENCES "report_submission"("report_submission_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "mc_report_data" ADD CONSTRAINT "mc_report_data_report_submission_id_fkey" FOREIGN KEY ("report_submission_id") REFERENCES "report_submission"("report_submission_id") ON DELETE RESTRICT ON UPDATE CASCADE;
