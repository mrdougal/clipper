
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
 
 -h		Display this help
 -r		Force reloading Generators list
 -p		Compute previews of the documents
 -t		Compute thumbnails of the documents
 -i		Compute thumbnail in icon mode
 -s size		Size for the thumbnail
 -f factor	Scale factor for the thumbnail
 -o dir		Output result in dir (don't display thumbnails or previews)
 
 
 */

int main (int argc, const char * argv[]) {
    
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	// Setup memory management

	int result = 0;													// Default status to return

	
	// Filemanager - Who will check, open and save files
	NSFileManager		*fm; 
	NSString			*inFileName, *outFileName
	NSFileHandle		*outFile;

	// For looking up arguments supplied to the application
	NSProcessInfo		*proc = [NSProcessInfo processInfo];
	NSArray				*args = [proc arguments];
	
	// Quicklook stuff
	NSURL				*inFileURL;
	CGImageRef			*qlThumb;
	NSBitmapImageRep	*qlBitmapRep;
	NSData				*qlBlob;
	

	
	fm = [[NSFileManager alloc] init];	// Create an instance of the filemanager
	
	//argv < 2
	if ([args count] < 2 ) {
		NSLog(@"No file supplied");
		return result;
	}
	
	inFileName = [args objectAtIndex: 1];
	
	// Check that the file exists
	if ([ fm isReadableFileAtPath: inFileName] == NO) {
		NSLog(@"Can't read %@", inFileName);
		return result;
	}
	
	inFileURL = [ NSURL fileURLWithPath: inFileName];	// Build url to file


	qlThumb = QLThumbnailImageCreate(nil, (CFURLRef)inFileURL, CGSizeMake(800, 800), nil);	// Ask Quicklook for a representation of the file

	if (qlThumb != nil) {
		
		outFileName = [ inFileName stringByAppendingString:@".png" ];
		
		[fm createFileAtPath: outFileName contents:nil attributes:nil];						// Create the outFile if required
		outFile = [ NSFileHandle fileHandleForWritingAtPath: outFileName];					// Create handle to the outFileName

		qlBitmapRep = [[NSBitmapImageRep alloc] initWithCGImage: qlThumb];					// Convert Quicklook result into bitmap
		qlBlob = [ qlBitmapRep representationUsingType: NSPNGFileType properties: nil ];	// Convert bitmap into a png

		if (qlBlob != nil) {
			[outFile writeData: qlBlob ];		// Write to file
		} else {
			NSLog(@"Errors in writing output from QuickLook");
			return result;
		}

		[outFile closeFile];					// Close open files
		result = 1;								// Set status to good
		
	} else {
		result = 0;								// Nothing was returned from Quicklook
	}

	
    [pool drain];
    return result;
}

