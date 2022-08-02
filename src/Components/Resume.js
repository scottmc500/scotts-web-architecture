import React, { Component } from 'react';

class Resume extends Component {
  render() {

    if(this.props.data){
      var skillmessage = this.props.data.skillmessage;
      var education = this.props.data.education.map(function(education){
        var educationPicture = 'images/education/' + education.picture
        return <div key={education.school}><img alt={education.school} src={educationPicture} /><h3>{education.school}</h3>
        <p className="info">{education.degree} <span>&bull;</span><em className="date">{education.graduated}</em></p>
        <p>{education.description}</p></div>
      })
      var work = this.props.data.work.map(function(work){
        var workPicture = 'images/work/' + work.picture
        return <div key={work.company}><img alt={work.company} src={workPicture} /><h3>{work.company}</h3>
            <p className="info">{work.title}<span>&bull;</span> <em className="date">{work.years}</em></p>
            <p>{work.description}</p>
	    <ul><li>Blah</li></ul>
        </div>
      })
      var skills = this.props.data.skills.map(function(skills){
        var skillPicture = 'images/tech/'+skills.picture;
        return <div key={skills.name} className="column">
                  <img className='skill' alt={skills.name} src={skillPicture} />
                  <h5>{skills.name}</h5>
                  <p>{skills.description}</p>
               </div>
      })
    }

    return (
      <section id="resume">

      <div className="row education">
         <div className="three columns header-col">
            <h1><span>Education</span></h1>
         </div>

         <div className="nine columns main-col">
            <div className="row item">
               <div className="twelve columns">
                 {education}
               </div>
            </div>
         </div>
      </div>


      <div className="row work">

         <div className="three columns header-col">
            <h1><span>Work</span></h1>
         </div>

         <div className="nine columns main-col">
          {work}
        </div>
    </div>



      <div className="row skill">

         <div className="three columns header-col">
            <h1><span>Skills</span></h1>
         </div>

        <div className="nine columns main-col">
          <p>{skillmessage}</p>
			  </div>
        
        <div className="bgrid-quarters s-bgrid-thirds cf">
          {skills}
        </div>
      </div>
   </section>
    );
  }
}

export default Resume;
