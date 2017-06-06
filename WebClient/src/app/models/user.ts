export class Credentials {
	username: string;
	password:  string;
}

export class UserMe {
	facebook_id:string;
	google_id: string;
	id: number;
	password:string;
	token:string;
	username:string;
}

export class LoginMessage {
	success: boolean;
	token: string;
	error: string;
}