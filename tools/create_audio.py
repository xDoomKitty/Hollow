"""Original synthesized sound palette; no samples or external assets."""
from pathlib import Path
import wave, math, random, struct
out=Path(__file__).resolve().parent.parent/'game/assets';out.mkdir(exist_ok=True)
rate=22050
random.seed(704219)
def write(name,seconds,fn):
 with wave.open(str(out/(name+'.wav')),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate)
  f.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,fn(i/rate,seconds)))*32767)) for i in range(int(rate*seconds))))
write('pick',.13,lambda t,d:math.sin(2*math.pi*(310+t*700)*t)*math.exp(-t*34)*.35)
write('find',.6,lambda t,d:(math.sin(2*math.pi*440*t)+math.sin(2*math.pi*660*t)*.45)*math.sin(math.pi*t/d)*.18)
write('build',.36,lambda t,d:(random.uniform(-1,1)*.7+math.sin(2*math.pi*100*t)*.4)*math.exp(-t*16)*.65)
write('hit',.17,lambda t,d:(random.uniform(-1,1)*.6+math.sin(2*math.pi*75*t))*math.exp(-t*24)*.4)
write('step',.12,lambda t,d:random.uniform(-1,1)*math.exp(-t*35)*.28)
write('alarm',1.3,lambda t,d:math.sin(2*math.pi*(180+60*math.sin(t*9))*t)*math.sin(math.pi*t/d)*.22)
write('underground',12,lambda t,d:(math.sin(2*math.pi*48*t)*.09+math.sin(2*math.pi*72*t)*.06+math.sin(2*math.pi*120*t)*.025)*(0.75+0.2*math.sin(2*math.pi*t/12)))
