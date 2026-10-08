const cron = require("node-cron");
const Appointment = require("../models/Appointment");
const Patient = require("../models/Patient");
const Doctor = require("../models/Doctor");
const { createNotification } = require("../services/notificationService");

// Run every minute
const startAppointmentReminderJob = () => {
    cron.schedule("* * * * *", async () => {
        try {
            const now = new Date();

            const reminderTime = new Date(
                now.getTime() + 24 * 60 * 60 * 1000
            );

            const startDate = new Date(reminderTime);
            startDate.setSeconds(0, 0);

            const endDate = new Date(startDate);
            endDate.setMinutes(endDate.getMinutes() + 1);

            const appointments = await Appointment.find({
                status: "confirmed",
                date: {
                    $gte: startDate,
                    $lt: endDate,
                },
            });

            for (const appointment of appointments) {
                const patient = await Patient.findById(
                    appointment.patientId
                );

                const doctor = await Doctor.findById(
                    appointment.doctorId
                );

                if (patient) {
                    await createNotification({
                        userId: patient.userId,
                        type: "appointment_reminder",
                        title: "Appointment Reminder",
                        message: `Your appointment is tomorrow at ${appointment.startTime}.`,
                        data: {
                            appointmentId: appointment._id,
                            doctorId: appointment.doctorId,
                        },
                    });
                }

                if (doctor) {
                    await createNotification({
                        userId: doctor.userId,
                        type: "appointment_reminder",
                        title: "Appointment Reminder",
                        message: `You have an appointment tomorrow at ${appointment.startTime}.`,
                        data: {
                            appointmentId: appointment._id,
                            patientId: appointment.patientId,
                        },
                    });
                }
            }
        } catch (error) {
            console.error(
                "Appointment reminder job error:",
                error
            );
        }
    });

    console.log("Appointment reminder job started");
};

module.exports = {
    startAppointmentReminderJob,
};