
/*
 
	This is an application for creating thumbnails of file via Quicklook
	This is my first cocoa application
 
	Friday 4th June 2010
	Dougal MacPherson <hello@newfangled.com.au>
 
 */

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
#import <AppKit/NSImage.h>
#import <AppKit/NSBitmapImageRep.h>


/*

 
 Arguments for qlmanage (ammended)
 We should try and follow these where possible
 
 -h			Display this help
 -i			Create thumbnail in icon mode
 -s size	Size for the thumbnail
 -o dir		Output result in file or dir
 
 
 */

void usageString(int exitCode)
{
	printf ("\n\nUsage: Clipper /path/to/input/file \n");
	printf ("[-s Size of thumbnail] \n");
	printf ("[-o Directory or file to write result to ] \n");
	printf ("[-h Display this message]\n");

	//printf ("[-i Create thumbnail in icon mode] \n");
	//printf ("\n\nif -i is specified, output will have additional OS X chrome such as page curls\n\n");
	
	exit(exitCode);
}

int main (int argc, const char * argv[]) {
    
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	// Setup memory management
	
	// Filemanager - Who will check, open and save files
	NSFileManager		*fm; 
	NSString			*inFileName, *outFileName;
	NSFileHandle		*outFile;
	Float64				*thumbSize;

	// For looking up arguments supplied to the application
	NSProcessInfo		*proc = [NSProcessInfo processInfo];
	NSArray				*args = [proc arguments];
	
	// Quicklook stuff
	NSURL				*inFileURL;
	CGImageRef			*qlThumb;
	NSBitmapImageRep	*qlBitmapRep;
	NSData				*qlBlob;

	fm = [[NSFileManager alloc] init];	// Create an instance of the filemanager
	int result = 1;						// Default status to return (which is bad)


	// Process the arguments and assign them to variables

	if ([args count] < 2 ) {
		NSLog(@"No file was supplied");
		printf("No file was supplied");
		usageString(result);
	}
	
	// Setup default values
	inFileName = [args objectAtIndex: 1];
	outFileName = [ inFileName stringByAppendingString:@".png" ];
	
//	thumbStyle = @"thumb";
//	thumbSize = (CGFloat) 800;
	
	for (int i = 2; i < argc; ++i) {
		if (!strcmp ("-s", argv[i])) {
			//thumbSize = (Float64) [[ args objectAtIndex: ++i] floatValue];
		}
		else if (!strcmp("-o", argv[i])) {
			outFileName = [args objectAtIndex: ++i];
		}
		else if (!strcmp ("-h", argv[i])) {
			usageString(result);
		}
		else {
			NSLog(@"Unknown command %s", [args objectAtIndex: i]);
			usageString(result);
		}
	}
	
	
	
	
	// Check that the file exists
	if ([ fm isReadableFileAtPath: inFileName] == NO) {
		
		NSLog(@"Can't read file %@", inFileName);
		//printf("Can't read file %s", inFileName);
		usageString(result);
	}
	
	inFileURL = [ NSURL fileURLWithPath: inFileName];	// Build url to file

	qlThumb = QLThumbnailImageCreate(nil, (CFURLRef)inFileURL, CGSizeMake(120,120), nil);	// Ask Quicklook for a representation of the file	


	if (qlThumb != nil) {
		
		[fm createFileAtPath: outFileName contents:nil attributes:nil];						// Create the outFile if required
		outFile = [ NSFileHandle fileHandleForWritingAtPath: outFileName];					// Create handle to the outFileName

		qlBitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: qlThumb];					// Convert Quicklook result into bitmap
		qlBlob = [ qlBitmapRep representationUsingType: NSPNGFileType properties: nil ];	// Convert bitmap into a png

		if (qlBlob != nil) {
			[outFile writeData: qlBlob ];		// Write to file
		} else {
			
			NSLog(@"Errors in writing output from Quicklook for file %@", inFileName);
		//	printf("Errors in writing output from QuickLook from %s", inFileName);
			usageString(result);
		}

		[outFile closeFile];					// Close open files
		result = 0;								// Set status to good
		
	} else {
		// Nothing was returned from Quicklook
		
		NSLog(@"QuickLook didn't return a thumbnail from %@", inFileName);
		//printf("Unable to get a thumbnail from QuickLook from %s", inFileName);
		result = 0;
	}

	
    [pool drain];
    return result;
}



