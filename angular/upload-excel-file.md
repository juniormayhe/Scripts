import.component.ts

```
import { Component, OnInit, ViewChild, ElementRef } from '@angular/core';
import { FileUploader } from 'ng2-file-upload';
import { RecipientService } from '../../_services/recipient.service';
import { AlertifyService } from '../../_services/alertify.service';
import { environment } from '../../../environments/environment';
import { NgForm } from '@angular/forms';
import { Router } from '@angular/router';

@Component({
  selector: 'app-import',
  templateUrl: './import.component.html',
  styleUrls: ['./import.component.css']
})
export class ImportComponent implements OnInit {
  uploader: FileUploader;
  hasBaseDropZoneOver = false;
  baseUrl = environment.apiUrl + 'youcontroller/';
  @ViewChild('uploadEl') uploadElRef: ElementRef;
  @ViewChild('editForm') editForm: NgForm;

  constructor(private recipientService: RecipientService,
    private alertifyService: AlertifyService,
    private router: Router) { }

  ngOnInit() {
    this.initializeUploader();
    this.uploader.onAfterAddingFile = (item => {
      this.uploadElRef.nativeElement.value = '';
     });
  }

  initializeUploader() {
    this.uploader = new FileUploader({
      url: this.baseUrl + 'your-import-action',
      authToken: 'Bearer ' + localStorage.getItem('token'),
      isHTML5: true,
      allowedMimeType: ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'],
      removeAfterUpload: true, /* remove from queue */
      autoUpload: false, /* user must start manually upload*/
      maxFileSize: 10 * 1024 * 1024 /* 10 mb */
    });

    this.uploader.onSuccessItem = (item, response, status, headers) => {
      this.uploadElRef.nativeElement.value = '';
      if (status === 204) {
        this.router.navigate(['/home']);
        this.alertifyService.success('Data imported');
      }
    }; // onSuccessItem
  }

  fileOverBase(e: any): void {
    this.hasBaseDropZoneOver = e;
  }
}
```

import.component.html
```
<div class="container">
  <form #editForm="ngForm" id="editForm" novalidate>
    <h2>Import data</h2>
    <p>here you can import your Excel file using this <a href="../../../assets/format.xlsx" target="_blank">Excel</a>.</p>

    <div ng2FileDrop [ngClass]="{'nv-file-over': hasBaseDropZoneOver}" (fileOver)="fileOverBase($event)" [uploader]="uploader"
      class="card bg-faded p-3 text-center mb-3 my-drop-zone">
      <i class="fa fa-upload fa-3x"></i>
      drag your file here
    </div>
    or browse your file...

    <div class="custom-file">
      <input #uploadEl type="file" ng2FileSelect [uploader]="uploader" class="custom-file-input" id="archivoExcel" 
        placeholder="Browse your Excel file (XLSX)..." 
        required>
      <label class="custom-file-label" for="archivoExcel">Choose an Excel...</label>
      <div class="invalid-feedback">Archivo inválido</div>
    </div>

    <div class="row" *ngIf="uploader.queue?.length">
      <div class="col">
        <h4>Selected file</h4>
        <table class="table">
          <thead>
            <tr>
              <th width="50%">Name</th>
              <th>Size</th>
            </tr>
          </thead>
          <tbody>
            <tr *ngFor="let item of uploader.queue">
              <td><strong>{{ item?.file?.name }}</strong></td>
              <td *ngIf="uploader.options.isHTML5" nowrap>{{ item?.file?.size/1024/1024 | number:'.2' }} MB</td>
            </tr>
          </tbody>
        </table>
        <div>
          <div>
            Progress:
            <div class="progress">
              <div class="progress-bar" role="progressbar" [ngStyle]="{ 'width': uploader.progress + '%' }"></div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <br>
        <button type="button" class="btn btn-primary btn-s" (click)="uploader.uploadAll()" [disabled]="!uploader.getNotUploadedItems().length" title="Upload file">
          <span class="fa fa-upload"></span> Confirm
        </button>
        <button type="button" class="btn btn-danger btn-s ml-10" (click)="uploader.clearQueue()" [disabled]="!uploader.queue.length" title="Remove file">
          <span class="fa fa-trash-o"></span>
        </button>
    <button type="button" class="btn btn-link" [routerLink]="['/home']">Go back</button>
  </form>
</div>
```
