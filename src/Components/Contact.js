import React, { Component } from 'react';
import $ from 'jquery';

class Contact extends Component {
   constructor(props) {
      super(props);
      this.state = {
         contactName: '',
         contactEmail: '',
         contactSubject: '',
         contactMessage: ''
      };
      this.handleChange.bind(this);
      this.handleSubmit.bind(this);
   }

   handleChange(e) {
      this.setState({ [e.target.name] : e.target.value });
   }

   handleSubmit(e) {
      e.preventDefault();

      $('#image-loader').fadeIn();
      $('#message-warning').fadeOut();

      const {contactName, contactEmail, contactSubject, contactMessage} = this.state;
      var data = JSON.stringify({
         "TableName": "Messages",
         "Item": {
            "timestamp": {
               "S": new Date().toISOString()
            },
            "name": {
               "S": contactName
            },
            "email": {
               "S": contactEmail
            },
            "subject": {
               "S": contactSubject
            },
            "message": {
               "S": contactMessage
            }
         }
      });

      console.log(process.env.REACT_APP_API_URL);
      $.ajax({
         type: "POST",
         url: process.env.REACT_APP_API_URL,
         data: data,
         dataType: "json",
         headers: {"x-api-key": process.env.REACT_APP_API_KEY}
      }).done(function(msg) {
         var str = JSON.stringify(msg);
         if (str === '{}') {
            $('#image-loader').fadeOut();
            $('#message-warning').hide();
            $('#contactForm').fadeOut();
            $('#message-success').fadeIn();
         } else {
            $('#image-loader').fadeOut();
            $('#message-warning').html(str);
            $('#message-warning').fadeIn();
         }
      }).fail(function(err) {
         $('#image-loader').fadeOut();
         $('#message-warning').html(JSON.stringify(err));
         $('#message-warning').fadeIn();
      });
   }
   
   render() {
      const {data} = this.props;

      if (data) {
         var name = data.name;
         var street = data.address.street;
         var city = data.address.city;
         var state = data.address.state;
         var zip = data.address.zip;
         var phone = data.phone;
         var message = data.contactmessage;
      }

      return (
         <section id="contact">
            <div className="row section-head">
            <div className="two columns header-col">
               <h1><span>Get In Touch.</span></h1>
            </div>
            <div className="ten columns">
                  <p className="lead">{message}</p>
            </div>
         </div>

         <div className="row">
            <div className="eight columns">
               <form id="contactForm"  name="contactForm" onSubmit={e => this.handleSubmit(e)}>
					<fieldset>
                  <div>
						   <label htmlFor="contactName">Name</label>
						   <input type="text" defaultValue="" size="35" id="contactName" name="contactName" value={this.state.contactName} onChange={e => this.handleChange(e)} required/>
                  </div>
                  <div>
                     <label htmlFor="contactEmail">Email</label>
                     <input type="text" defaultValue="" size="35" id="contactEmail" name="contactEmail" value={this.state.contactEmail} onChange={e => this.handleChange(e)} required/>
                  </div>
                  <div>
						   <label htmlFor="contactSubject">Subject</label>
						   <input type="text" defaultValue="" size="35" id="contactSubject" name="contactSubject" value={this.state.contactSubject} onChange={e => this.handleChange(e)} required/>
                  </div>
                  <div>
                     <label htmlFor="contactMessage">Message</label>
                     <textarea cols="50" rows="15" id="contactMessage" name="contactMessage" value={this.state.contactMessage} onChange={e => this.handleChange(e)} required/>
                  </div>

                  <div>
                     <button className="submit">Submit</button>
                     <span id="image-loader">
                        <img alt="" src="images/loader.gif" />
                     </span>
                  </div>
					</fieldset>
				   </form>

           <div id="message-warning"> Error boy</div>
				   <div id="message-success">
                  <i className="fa fa-check"></i>Your message was sent, thank you!<br />
				   </div>
           </div>

            <aside className="four columns footer-widgets">
               <div className="widget widget_contact">
					   <h4>Address and Phone</h4>
					   <p className="address">
						   {name}<br />
						   {street} <br />
						   {city}, {state} {zip}<br />
						   <span>{phone}</span>
					   </p>
				   </div>
            </aside>
         </div>
      </section>
   );
  }
}

export default Contact;
