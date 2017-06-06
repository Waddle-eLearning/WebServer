import { NgModule } from '@angular/core';

import { HeaderModule } from './header/header.module';
import { SidenavModule } from './sidenav/sidenav.module';
import {LayoutRoutingModule} from "./layout-routing.module";

@NgModule({
	imports: [
		HeaderModule,
		SidenavModule,
		LayoutRoutingModule,
	],
	exports: [
		SidenavModule,
	],
})

export class LayoutModule { }
