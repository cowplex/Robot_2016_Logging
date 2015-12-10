# Version 0.1

data_offset = 0

data = data.frame("Time" = integer(), "Data_offset" = integer(), "Sem_update" = integer(), "FL_out" = integer(), "FL_current" = integer(), "FL_busvolt" = integer(), "BL_out" = integer(), "BL_current" = integer(), "BL_busvolt" = integer(), "BR_out" = integer(), "BR_current" = integer(), "BR_busvolt" = integer(), "FR_out" = integer(), "FR_current" = integer(), "FR_busvolt" = integer(), "Drive_loops" = integer(), "Drive_update" = integer(), stringsAsFactors=FALSE);

readfile = file("~/Projects/Robotics/2016/Logging/Tele-1449535617026.log", "rb");

while(length(chirpval <- readBin(readfile, integer(), size = 1, endian = "big")) > 0)
{
	if(chirpval != 94)
		print(data_offset);

	match_time = readBin(readfile, integer(), size = 8, endian = "big");
	current_offset = data_offset;
	
	# Keep track of the current offset in the data file
	data_offset = data_offset+10;
	
	# Read the mask to determine what classes logged
	mask = readBin(readfile, integer(), size = 1, endian = "big");
	
	# Semaphore data
	if(bitwAnd(mask, 1))
	{
		semaphore = readBin(readfile, integer(), size = 8, endian = "big");
		data_offset = data_offset+8;
	} else {
		semaphore = NA;
	}
	
	# Drive data
	if(bitwAnd(mask, 2))
	{
		data_offset = data_offset+24;
		drive = c(
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			readBin(readfile, integer(), size = 1, endian = "big"),
			
			readBin(readfile, integer(), size = 4, endian = "big"),	
			
			readBin(readfile, integer(), size = 8, endian = "big")
		);
	}
	else
	{
		drive = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0, NA);
	}
	
	# Add current loop data to the data frame
	data[nrow(data)+1, ] = c(match_time, current_offset, semaphore, drive);
}
close(readfile);

data$Update_time = data$Time;
for(i in 2:length(test$Time))
{
	data$Update_time[i] = data$Time[i] - data$Time[i-1];
}