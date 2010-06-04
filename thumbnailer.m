
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


int main (int argc, const char * argv[]) {
    
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];	// Setup memory management

	int result = 0;													// Default status to return

	
	// Filemanager - Who will check, open and save files
	NSFileManager		*fm; 
	NSString			*inFileName = @"assets/example.pdf";
	NSString			*outFileName = @"thumbs/thumb.png";
	NSString			*pwd;
	NSFileHandle		*outFile;
	
	// Quicklook stuff
	NSURL				*inFileURL;
	CGImageRef			*qlThumb;
	NSBitmapImageRep	*qlBitmapRep;
	NSData				*qlBlob;
	

	
	fm = [[NSFileManager alloc] init];	// Create an instance of the filemanager
	pwd = [ fm currentDirectoryPath];	// Our current directory
	inFileURL = [ NSURL fileURLWithPath: [pwd stringByAppendingPathComponent: inFileName]];	// Build url to file
	
	// Check that the file exists
	if ([ fm fileExistsAtPath: inFileName] == NO) {
		NSLog(@"File doesn't exist!");
		return result;
	}
	
	

	qlThumb = QLThumbnailImageCreate(nil, (CFURLRef)inFileURL, CGSizeMake(800, 800), nil);	// Ask Quicklook for a representation of the file

	if (qlThumb != nil) {
		
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
