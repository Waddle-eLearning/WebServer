import {Pipe} from "@angular/core";
@Pipe({
	name: 'uriEncode'
})

export class UriDecodePipe {
	transform(input: any, args: Array<any>): string {
		return decodeURIComponent(input);
	}
}
