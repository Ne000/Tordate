class CounterevidenceController < ApplicationController
respond_to :json
    def add
    a=Counterevidence.create(counter_params)
    respond_with(a.update(score:0))  
    end
    
    def vote
    if params[:up]=="true" then params[:up]=true else params[:up]=false end
    vote=VoteEvidence.where(user_id:@user.id,evidence_id:params[:id]).first
    counter=Counterevidence.find(params[:id])
    if counter.score.nil? then counter.score=0 end
    if(vote.blank?) then
        #CASO 1: PRIMER VOTO / LO CUENTO
        VoteEvidence.create(user_id:@user.id,evidence_id:params[:id],is_up:params[:up])
        if params[:up] then counter.update(score:counter.score+(get_config("vote_power").to_i)) else counter.update(score:counter.score-(get_config("vote_power").to_i)) end
        render json:{"changed"=>true}
   else if(!vote.is_up) then
        #CASO 2: HABIA VOTADO HACIA ABAJO
            if params[:up]
                vote.update(is_up:true)
                counter.update(score:counter.score+(get_config("vote_power").to_i)*2)
                render json:{"changed"=>true}
            else
            #CASO 3: YA HABIA VOTADO HACIA ABAJO, ESTA BORRANDOLO!
                vote.destroy
                counter.update(score:counter.score+(get_config("vote_power").to_i))
                render json:{"changed"=>true,"destroyed"=>true}
            end
        else
        #CASO 4: HABIA VOTADO HACIA ARRIBA
            if !params[:up]
                vote.update(is_up:false)
                counter.update(score:counter.score-(get_config("vote_power").to_i)*2)
                render json:{"changed"=>true}
            else
            #CASO 5 : YA HABIA VOTADO HACIA ARRIBA, ESTA BORRANDOLO!
                vote.destroy
                counter.update(score:counter.score-(get_config("vote_power").to_i))
                render json:{"changed"=>true,"destroyed"=>true}
            end
        end
       end

    end
    
    private
    def counter_params
        params.require(:counterevidence).permit(:description,:url,:article_id)
    end
end
