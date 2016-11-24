module BrNfe
	module Product
		class NotaFiscal  < BrNfe::ActiveModelBase
			include BrNfe::Association::HaveDestinatario
			include BrNfe::Association::HaveEmitente
			# include BrNfe::Association::HaveCondicaoPagamento
			
			# Código do Tipo de Emissão da NF-e
			#  ✓ 1=Emissão normal (não em contingência);
			#  ✓ 6=Contingência SVC-AN (SEFAZ Virtual de Contingência do AN);
			#  ✓ 7=Contingência SVC-RS (SEFAZ Virtual de Contingência do RS);
			#  ✓ 9=Contingência off-line da NFC-e (as demais opções de contingência são válidas 
			#      também para a NFC-e).
			#  Para a NFC-e somente estão disponíveis e são válidas as opções de contingência 5 e 9.
			# 
			# <b>Type:     </b> _Number_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _1_
			# <b>Length:   </b> _1_
			# <b>tag:      </b> tpEmis
			#
			attr_accessor :codigo_tipo_emissao
			alias_attribute :tpEmis, :codigo_tipo_emissao


			attr_accessor :chave_de_acesso

			def chave_de_acesso_dv
				chave_de_acesso[-1]
			end
			def chave_de_acesso_sem_dv
				chave_de_acesso[0..-2]
			end
			def chave_de_acesso
				@chave_de_acesso ||= gerar_chave_de_acesso!
			end


			# Código numérico que compõe a Chave de Acesso. Número aleatório gerado pelo 
			# emitente para cada NF-e para evitar acessos indevidos da NF-e.
			# Resumo: É um código controlado pelo sistema. Pode por exemplo ser
			#        utilizado o ID da tabela da nota fiscal.
			# 
			# <b>Type:     </b> _Number_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _nil_
			# <b>Length:  </b> _max: 8_
			# <b>tag:      </b> cNF
			#
			attr_accessor :codigo_nf
			alias_attribute :cNF, :codigo_nf

			
			# Série do Documento Fiscal, preencher com zeros na hipótese
			# de a NF-e não possuir série. (v2.0) 
			# Série 890-899: uso exclusivo para emissão de NF-e avulsa, pelo
			#    contribuinte com seu certificado digital, através do site do Fisco
			#    (procEmi=2). (v2.0)
			# Serie 900-999: uso exclusivo de NF-e emitidas no SCAN. (v2.0)
			#
			# <b>Type:     </b> _Number_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _nil_
			# <b>Length:   </b> _max: 3_
			# <b>tag:      </b> serie
			#
			attr_accessor :serie

			# Número do Documento Fiscal.
			# Número da nota fiscal De fato
			#
			# <b>Type:     </b> _Number_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _nil_
			# <b>Length:   </b> _max: 9_
			# <b>tag:      </b> nNF
			#
			attr_accessor :numero_nf
			alias_attribute :nNF, :numero_nf

			# Descrição da Natureza da Operação
			# Informar a natureza da operação de que decorrer a saída ou a
			# entrada, tais como: venda, compra, transferência, devolução,
			# importação, consignação, remessa (para fins de demonstração,
			# de industrialização ou outra), conforme previsto na alínea 'i',
			# inciso I, art. 19 do CONVÊNIO S/No, de 15 de dezembro de
			# 1970.
			#
			# <b>Type:     </b> _String_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _'Venda'_
			# <b>tag:      </b> natOp
			#
			attr_accessor :natureza_operacao
			alias_attribute :natOp, :natureza_operacao

			# Indicador da forma de pagamento
			# 0=Pagamento à vista; (Default)
			# 1=Pagamento a prazo;
			# 2=Outros.
			#
			# <b>Type:     </b> _Number_ OR _String_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _0_
			# <b>Length:   </b> _1_
			# <b>tag:      </b> indPag
			#
			attr_accessor :forma_pagamento
			alias_attribute :indPag, :forma_pagamento

			# Código do Modelo do Documento Fiscal
			# 55=NF-e emitida em substituição ao modelo 1 ou 1A; (Default)
			# 65=NFC-e, utilizada nas operações de venda no varejo (a critério da UF aceitar este modelo de documento).
			#
			# <b>Type:     </b> _Number_ OR _String_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _55_
			# <b>Length:   </b> _2_
			# <b>tag:      </b> mod
			#
			attr_accessor :modelo_nf
			alias_attribute :mod, :modelo_nf

			# Data e hora de emissão do Documento Fiscal
			#
			# <b>Type:     </b> _Time_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _Time.current_
			# <b>tag:      </b> dhEmi
			#
			attr_accessor :data_hora_emissao
			def data_hora_emissao
				convert_to_time(@data_hora_emissao)
			end
			alias_attribute :dhEmi, :data_hora_emissao

			# Data e hora de Saída ou da Entrada da Mercadoria/Produto
			# Campo não considerado para a NFC-e.
			#
			# <b>Type:     </b> _Time_
			# <b>Required: </b> _Yes_ (apenas para modelo 55)
			# <b>Default:  </b> _Time.current_
			# <b>tag:      </b> dhSaiEnt
			#
			attr_accessor :data_hora_expedicao
			def data_hora_expedicao
				convert_to_time(@data_hora_expedicao)
			end
			alias_attribute :dhSaiEnt, :data_hora_expedicao

			# Tipo de Operação
			# 0=Entrada;
			# 1=Saída (Default)
			#
			# <b>Type:     </b> _Number_ OR _String_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _1_
			# <b>Length:   </b> _1_
			# <b>tag:      </b> tpNF
			#
			attr_accessor :tipo_operacao
			alias_attribute :tpNF, :tipo_operacao

			# Formato de Impressão do DANFE
			# 0=Sem geração de DANFE;
			# 1=DANFE normal, Retrato; (Default)
			# 2=DANFE normal, Paisagem;
			# 3=DANFE Simplificado;
			# 4=DANFE NFC-e;
			# 5=DANFE NFC-e em mensagem eletrônica (o envio de mensagem eletrônica pode
			#   ser feita de forma simultânea com a impressão do DANFE; usar o tpImp=5 
			#   quando esta for a única forma de disponibilização do DANFE).
			#
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _1_
			# <b>tag:      </b> tpEmis
			#
			attr_accessor :tipo_impressao
			alias_attribute :tpEmis, :tipo_impressao

			# Finalidade de emissão da NF-e
			# 1=NF-e normal; (Default)
			# 2=NF-e complementar;
			# 3=NF-e de ajuste;
			# 4=Devolução de mercadoria.
			#
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _1_
			# <b>tag:      </b> finNFe
			#
			attr_accessor :finalidade_emissao
			alias_attribute :finNFe, :finalidade_emissao


			# Indica operação com Consumidor final
			# false=Normal;
			# true=Consumidor final;
			#
			# Preencher esse campo com true ou false
			#
			# <b>Type:     </b> _Boolean_
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _false_
			# <b>tag:      </b> indFinal
			#
			attr_accessor :consumidor_final
			def consumidor_final
				convert_to_boolean(@consumidor_final)
			end
			alias_attribute :indFinal, :consumidor_final

			# Indicador de presença do comprador no estabelecimento comercial no 
			# momento da operação:
			#   0=Não se aplica (por exemplo, Nota Fiscal complementar ou de ajuste);
			#   1=Operação presencial;
			#   2=Operação não presencial, pela Internet;
			#   3=Operação não presencial, Teleatendimento;
			#   4=NFC-e em operação com entrega a domicílio;
			#   9=Operação não presencial, outros. (Default)
			#
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _9_
			# <b>tag:      </b> indPres
			#
			attr_accessor :presenca_comprador
			alias_attribute :indPres, :presenca_comprador

			# Processo de emissão da NF-e
			# 0=Emissão de NF-e com aplicativo do contribuinte; (Default)
			# 1=Emissão de NF-e avulsa pelo Fisco;
			# 2=Emissão de NF-e avulsa, pelo contribuinte com seu certificado digital, através do site do Fisco;
			# 3=Emissão NF-e pelo contribuinte com aplicativo fornecido pelo Fisco.
			#
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _0_
			# <b>tag:      </b> procEmi
			#
			attr_accessor :processo_emissao
			alias_attribute :procEmi, :processo_emissao

			# Versão do Processo de emissão da NF-e
			# Informar a versão do aplicativo emissor de NF-e.
			#
			# <b>Required: </b> _Yes_
			# <b>Default:  </b> _0_
			# <b>tag:      </b> verProc
			#
			attr_accessor :versao_aplicativo
			alias_attribute :verProc, :versao_aplicativo

			# Endereço da retirada da mercadoria
			#
			# <b>Type:     </b> _BrNfe.endereco_class_
			# <b>Required: </b> _No_
			# <b>Default:  </b> _nil_
			# <b>tag:      </b> retirada
			#
			has_one :endereco_retirada, 'BrNfe.endereco_class'
			alias_attribute :retirada, :endereco_retirada
			
			# CPF ou CNPJ do local de retirada da mercadoria.
			# Só é obrigatório se o endereco_retirada for preenchido
			#
			# <b>Type:     </b> _String_
			# <b>Required: </b> _No_ (_Yes_ if endereco_retirada is present)
			# <b>Default:  </b> _nil_
			# <b>tag:      </b> retirada/CPF ou retirada/CNPJ
			#
			attr_accessor :endereco_retirada_cpf_cnpj
			def endereco_retirada_cpf_cnpj
				return unless @endereco_retirada_cpf_cnpj.present?
				BrNfe::Helper::CpfCnpj.new(@endereco_retirada_cpf_cnpj).sem_formatacao
			end


			# Endereço da entrega da mercadoria
			# Informar apenas quando for diferente do endereço do destinatário
			#
			# <b>Type:     </b> _BrNfe.endereco_class_
			# <b>Required: </b> _No_
			# <b>Default:  </b> _nil_
			# <b>tag:      </b> entrega
			#
			has_one :endereco_entrega, 'BrNfe.endereco_class'
			alias_attribute :entrega, :endereco_entrega
			
			# CPF ou CNPJ do local de entrega da mercadoria.
			# Só é obrigatório se o endereco_entrega for preenchido
			#
			# <b>Type:     </b> _String_
			# <b>Required: </b> _No_ (_Yes_ if endereco_entrega is present)
			# <b>Default:  </b> _nil_
			# <b>tag:      </b> entrega/CPF ou entrega/CNPJ
			#
			attr_accessor :endereco_entrega_cpf_cnpj
			def endereco_entrega_cpf_cnpj
				return unless @endereco_entrega_cpf_cnpj.present?
				BrNfe::Helper::CpfCnpj.new(@endereco_entrega_cpf_cnpj).sem_formatacao
			end

			# CPF ou CNPJ das pessoas que estão autorizadas a fazer o download do XML da NF-e.
			# Deve ser um Array com os CPF's e CNPJ's válidos.
			#
			# <b>Type:     </b> _Array_
			# <b>Required: </b> _No_
			# <b>Default:  </b> _[]_
			# <b>tag:      </b> autXML
			#
			attr_accessor :autorizados_download_xml
			def autorizados_download_xml
				@autorizados_download_xml = [@autorizados_download_xml].flatten unless @autorizados_download_xml.is_a?(Array)
				@autorizados_download_xml.compact!
				@autorizados_download_xml
			end
			alias_attribute :autXML, :autorizados_download_xml

			# Transporte da mercadoria
			# Informações referentes ao transporte da mercadoria.
			#
			# <b>Type:     </b> _BrNfe.transporte_product_class_
			# <b>Required: </b> _No_
			# <b>Default:  </b> _nil_
			# <b>tag:      </b> transp
			#
			has_one :transporte, 'BrNfe.transporte_product_class'
			alias_attribute :transp, :transporte

			# Dados da cobrança da NF-e
			# Fatura e Duplicatas da Nota Fiscal
			# Utilizado para especificar os dados da fatura e das duplicatas.
			# No caso desta GEM, a fatura contém o Array de duplicatas.
			# Ex:
			#    self.fatura.duplicatas
			#    => [#<::Cobranca::Duplicata:0x00000006302b80 ...>, #<::Cobranca::Duplicata:0x00000046465bw4 ...>] 
			#
			# <b>Type:     </b> _BrNfe.fatura_product_class_
			# <b>Required: </b> _No_
			# <b>Default:  </b> _nil_
			# <b>Exemplo:  </b> _BrNfe::Product::Nfe::Cobranca::Fatura.new(numero_fatura: 'FAT646498'...)_
			# <b>tag:      </b> cobr
			#
			has_one :fatura, 'BrNfe.fatura_product_class'
			alias_attribute :cobranca, :fatura
			alias_attribute :cobr, :fatura
			
			# Array com as informações dos pagamentos
			# IMPORTANTE: Utilizado apenas para NFC-e
			#
			# Pode ser adicionado os dados dos pagamentos em forma de `Hash` 
			# ou o próprio objeto da classe BrNfe.pagamento_product_class.
			#
			# Exemplo com Hash:
			#    self.pagamentos = [{forma_pagamento: '1', total: 100.00, ...},{forma_pagamento: '2', total: 200.00, ...}]
			#    self.pagamentos << {forma_pagamento: '3', total: 300.00, ...}
			#    self.pagamentos << {forma_pagamento: '4', total: 400.00, ...}
			#
			# Exemplo com Objetos:
			#    self.pagamentos = [BrNfe::Product::Nfe::Cobranca::Pagamento.new({forma_pagamento: '5', total: 500.00, ...}),{forma_pagamento: '11', total: 600.00, ...}]
			#    self.pagamentos << BrNfe::Product::Nfe::Cobranca::Pagamento.new({forma_pagamento: '10', total: 700.00, ...})
			#    self.pagamentos << {forma_pagamento: '12', total: 800.00, ...}
			#
			# Sempre vai retornar um Array de objetos da class configurada em `BrNfe.pagamento_product_class`
			#
			# <b>Tipo:    </b> _BrNfe.pagamento_product_class (BrNfe::Product::Nfe::Cobranca::Pagamento)_
			# <b>Min:     </b> _0_
			# <b>Max:     </b> _100_
			# <b>Default: </b> _[]_
			# <b>tag:     </b> pag
			#
			has_many :pagamentos, 'BrNfe.pagamento_product_class'
			alias_attribute :pag, :pagamentos

			def default_values
				{
					versao_aplicativo:   0, 
					natureza_operacao:   'Venda',
					forma_pagamento:     0, # 0=À vista
					modelo_nf:           55, #NF-e
					data_hora_emissao:   Time.current,
					data_hora_expedicao: Time.current,
					tipo_operacao:       1, # 1=Saída
					tipo_impressao:      1, # 1=DANFE normal, Retrato;
					finalidade_emissao:  1, # 1=NF-e normal;
					presenca_comprador:  9, # 9=Operação não presencial, outros.
					processo_emissao:    0, # 0=Emissão de NF-e com aplicativo do contribuinte;
					codigo_tipo_emissao: 1, # 1=Normal
				}
			end

			validates :codigo_tipo_emissao, presence: true
			validates :codigo_tipo_emissao, inclusion: [1, 6, 7, 9, '1', '6', '7', '9']
			
			validates :codigo_nf, presence: true
			validates :codigo_nf, numericality: { only_integer: true }
			validates :codigo_nf, length: { maximum: 8 }
			
			validates :serie, presence: true
			validates :serie, numericality: { only_integer: true }
			validates :serie, length: { maximum: 3 }
			validates :serie, exclusion: [890, 899, 990, 999, '890', '899', '990', '999']
			
			validates :numero_nf, presence: true
			validates :numero_nf, numericality: { only_integer: true }
			validates :numero_nf, length: { maximum: 9 }
			
			validates :natureza_operacao, presence: true
			
			validates :forma_pagamento, presence: true
			validates :forma_pagamento, inclusion: [0, 1, 2, '0', '1', '2']
			
			validates :modelo_nf, presence: true
			validates :modelo_nf, inclusion: [55, 65, '55', '65']

			validates :data_hora_emissao, presence: true
			validates :data_hora_expedicao, presence: true, if: :nfe?
			
			validates :tipo_operacao, presence: true
			validates :tipo_operacao, inclusion: [0, 1, '0', '1']

			validates :tipo_impressao, presence: true
			validates :tipo_impressao, inclusion: [0, 1, 2, 3, 4, 5, '0', '1', '2', '3', '4', '5']
			
			validates :presenca_comprador, presence: true
			validates :presenca_comprador, inclusion: [0, 1, 2, 3, 4, 9, '0', '1', '2', '3', '4', '9']
			
			validates :processo_emissao, presence: true
			validates :processo_emissao, inclusion: [0, 1, 2, 3, '0', '1', '2', '3']

			validates :autorizados_download_xml, length: { maximum: 10 }
			
			with_options if: :nfce? do |record|
				record.validate_has_many :pagamentos
				record.validates :pagamentos, length: {maximum: 100}
			end

			validate_has_one  :transporte
			validate_has_one  :fatura
			
			validate_has_one  :endereco_retirada
			with_options if: :endereco_retirada do |record|
				record.validates :endereco_retirada_cpf_cnpj, presence: true
				record.validates :endereco_retirada_cpf_cnpj, length: {maximum: 14}
			end

			validate_has_one  :endereco_entrega
			with_options if: :endereco_entrega do |record|
				record.validates :endereco_entrega_cpf_cnpj, presence: true
				record.validates :endereco_entrega_cpf_cnpj, length: {maximum: 14}
			end
			

			def nfe?
				modelo_nf.to_i == 55
			end
			def nfce?
				modelo_nf.to_i == 65
			end

		private

			def destinatario_class
				BrNfe.destinatario_product_class
			end

			def emitente_class
				BrNfe.emitente_product_class
			end

			###############################################################################################
			#       | Código | AAMM da | CNPJ do  | Modelo | Série | Número  | Cód. tipo | Código   | DV  |
			#       | da UF  | emissão | Emitente |        |       | da NF-e | emissão   | Numérico |     |
			#       ---------------------------------------------------------------------------------------
			# Tam = |  02    |   04    |    14    |   02   |   03  |   09    |    01     |    08    | 01  |
			#       °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
			def gerar_chave_de_acesso!
				chave_sem_dv =  "#{emitente.endereco.codigo_ibge_uf}"
				chave_sem_dv << "#{data_hora_emissao.try(:strftime, '%y%m')}"
				chave_sem_dv << "#{emitente.cnpj}".rjust(14,'0')
				chave_sem_dv << "#{modelo_nf}"
				chave_sem_dv << "#{serie}".rjust(3, '0')
				chave_sem_dv << "#{numero_nf}".rjust(9, '0')
				chave_sem_dv << "#{codigo_tipo_emissao}"
				chave_sem_dv << "#{codigo_nf}".rjust(8, '0')
				dv = BrNfe::Calculos::Modulo11FatorDe2a9RestoZero.new(chave_sem_dv)
				"#{chave_sem_dv}#{dv}"
			end
		end
	end
end