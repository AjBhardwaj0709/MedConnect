const mongoose = require("mongoose")

const doctorAvailabilitySchema = new mongoose.Schema({
    doctorId:{
        type:mongoose.Schema.Types.ObjectId,
        ref:"doctor"
        ,
        required: true,

    },
     daysOfWeek:{
        type:String,
         enum: ["monday",
             "tuesday",
             "wednesday",
             "thursday",
             "friday",
             "saturday",
             "sunday",],
             required:true,

     },
     startTime:{
        type:String,
        required:true,
         match: /^([01]\d|2[0-3]):([0-5]\d)$/,
     },
     endTime:{
        type:String,
        required:true,
        match: /^([01]\d|2[0-3]):([0-5]\d)$/,
     },
     isAvailable:{
        type: Boolean,
        default: true
     },

},{
    timestamps:true  
});
module.exports=moongoose.model(
    "DoctorAvailability",
    doctorAvailabilitySchema
);