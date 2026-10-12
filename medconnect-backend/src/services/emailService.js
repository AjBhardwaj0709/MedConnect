
const { Resend } = require("resend");

const resend = new Resend(process.env.RESEND_API_KEY);

const sendEmail = async ({ to, subject, html }) => {
    if (!process.env.RESEND_API_KEY || !process.env.EMAIL_FROM) {
        throw new Error("Email service environment variables are missing");
    }

    const { data, error } = await resend.emails.send({
        from: process.env.EMAIL_FROM,
        to,
        subject,
        html,
    });

    if (error) {
        console.error("Email provider error:", error);
        throw new Error("Email could not be sent");
    }

    return data;
};

module.exports = { sendEmail };
